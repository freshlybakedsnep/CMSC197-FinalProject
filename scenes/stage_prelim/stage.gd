extends Node
class_name Stage

signal stage_quit

const WORLD_SCENE := "res://scenes/player_world/world.tscn"
const MAIN_MENU_SCENE := "res://scenes/menu/main_menu.tscn"
const WIN_TITLE := "Stage Cleared!"
const WIN_HINT_DEFAULT := "Your party won the battle."
const LOSE_TITLE := "The Party has fallen..."
const LOSE_HINT_DEFAULT := "Your team was defeated."

@onready var state_machine: GameStateMachine = $StateMachine

@onready var command_ui: BattleMenu = $CommandUI
@onready var enemies : EnemyFormation = $Enemies
@onready var heroes : HeroFormation = $Heroes
@onready var interval: Timer = $Interval
@onready var pause_modal = $PauseModal
@onready var end_screen: CanvasLayer = $EndScreen
@onready var result_title: Label = $EndScreen/ModalRoot/CenterContainer/Panel/VBoxContainer/Label
@onready var result_hint: Label = $EndScreen/ModalRoot/CenterContainer/Panel/VBoxContainer/Hint
@onready var result_retry_button: Button = $EndScreen/ModalRoot/CenterContainer/Panel/VBoxContainer/Buttons/Retry
@onready var result_exit_button: Button = $EndScreen/ModalRoot/CenterContainer/Panel/VBoxContainer/Buttons/Exit

@export var stage_info : StageInfo

var current_wave : Array[EnemyData]
var current_wave_index := -1

var turn_count := 0
var turn_queue : Array[Entity]

var acted : Array[Entity]
var eliminated : Array[Entity]
var pending_triggers : Array[Dictionary] = []

func _ready() -> void:
	BGM.play_battle()
	state_machine.handler = self
	pause_modal.resume_requested.connect(_on_pause_resume_requested)
	pause_modal.exit_battle_requested.connect(_on_pause_exit_battle_requested)
	pause_modal.exit_game_requested.connect(_on_pause_exit_game_requested)
	if not result_retry_button.pressed.is_connected(_on_result_retry_pressed):
		result_retry_button.pressed.connect(_on_result_retry_pressed)
	if not result_exit_button.pressed.is_connected(_on_result_exit_pressed):
		result_exit_button.pressed.connect(_on_result_exit_pressed)
	_set_result_modal(LOSE_TITLE, LOSE_HINT_DEFAULT)
	
	heroes.setup(eliminated)
	enemies.setup(eliminated)
	command_ui.connect_formations(enemies, heroes)
	
	load_next_wave()
	
	state_machine.register_state(&"start", BattleEvents.TurnStart)
	state_machine.register_state(&"plan", BattleEvents.PlanState)
	state_machine.register_state(&"combat", BattleEvents.CombatState)
	state_machine.register_state(&"act", BattleEvents.ActingState)
	state_machine.register_state(&"end", BattleEvents.TurnEnd)
	state_machine.register_state(&"async", BattleEvents.AsyncEffectState)
	
	state_machine.register_state(&"win", BattleEvents.Win)
	state_machine.register_state(&"lose", BattleEvents.GameOver)
	
	state_machine.change(&"start")
	state_machine._process_pending()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if get_tree().paused:
			return
		pause_modal.open_menu()
		get_viewport().set_input_as_handled()

func load_next_wave() -> bool:
	current_wave_index += 1
	$Wave.text = "Wave: %s/%s" % [current_wave_index+1, stage_info.waves.size()] 
	if current_wave_index >= stage_info.waves.size():
		return false
	
	print(current_wave_index + 1, "/", stage_info.waves.size())
	var curr_wave = stage_info.load_wave(current_wave_index)
	enemies.load_wave(curr_wave)
	return true

func update_turn_order() -> void:
	turn_queue.clear()
	for unit in get_tree().get_nodes_in_group("entities"):
		unit = unit as Entity
		unit.highlight_me(false)
		unit.outline_me(false)
		
		if (not is_instance_valid(unit) or 
			eliminated.has(unit) or 
			acted.has(unit) or 
			unit.data.state == EntityData.State.DEAD):
			continue
		turn_queue.append(unit)
		
	turn_queue.sort_custom(func(a, b):
		var ap = _get_prio(a)
		var bp = _get_prio(b)
		
		if ap != bp: return ap > bp
		return _get_spd(a) > _get_spd(b)
	)

func start_turn() -> void:
	turn_count += 1
	$TurnCount.text = "Turn: " + str(turn_count)
	
	enemies.fill_vacancies()
	$EnemyCount.text = "Enemies Left: " + str(enemies.enemy_pool.size())
	
	for e: Entity in get_tree().get_nodes_in_group("entities"):
		if e.data.state == EntityData.State.NORMAL:
			e.reset()
			trigger_event(e, StatusComponent.Trigger.ON_TURN_START)
	print("\nTurn %d" % turn_count)

func end_turn() -> void:
	RenderingServer.global_shader_parameter_set("screen_dim_amount", 1.0)
	acted.clear()
	for e: Entity in get_tree().get_nodes_in_group("entities"):
		if e.data.state == EntityData.State.NORMAL:
			trigger_event(e, StatusComponent.Trigger.ON_TURN_END)

func trigger_event(ent: Entity, event: StatusComponent.Trigger) -> void:
	var status : StatusComponent = ent.data.get_comp(EntityComponent.Type.STATUS)
	if not status: return
	var e = status.tick_hits(event)
	if e:
		match e[&"type"]:
			StatusEffect.Behavior.EOT:
				pending_triggers.append(
					{
						&"state_name" : "async",
						&"host": e[&"tar"],
						&"call": func(): ActionParser.apply_dot_effect(e[&"src"], e[&"tar"], e[&"eff"])
					}
				)

func _get_prio(ent: Entity) -> int:
	var act_sys : ActionComponent = ent.data.get_comp(EntityComponent.Type.ACTION)
	var cont = ent.data.get_comp(EntityComponent.Type.CONTROLLER)
	if act_sys and cont:
		return act_sys.get_priority(cont.queued_action)
	return 0

func _get_spd(ent: Entity)-> int:
	var stat : StatsComponent = ent.data.get_comp(EntityComponent.Type.STATS)
	if stat:
		return stat.get_stat("SPD")
	return 0

func clear_the_dead() -> void:
	if !eliminated: return
	var targets = eliminated.duplicate()
	eliminated.clear()
	for ent in targets:
		if not is_instance_valid(ent): continue
		
		if ent.is_in_group("died"): continue
		ent.add_to_group("died")
		await ent.die()
		ent.data.state = EntityData.State.DEAD
		if ent.data.faction == EntityData.Faction.ENEMY:
			enemies.remove_from_formation(ent)
			print(ent.name, " is deleted")
			ent.queue_free()
		ent.remove_from_group("entities")

func get_next_state() -> String:
	if pending_triggers.is_empty(): return ""
	return pending_triggers.front().get(&"state_name")

func process_pending() -> Dictionary:
	if pending_triggers.is_empty(): return {}
	return pending_triggers.pop_front()

func on_battle_won() -> void:
	var win_result := PartyManager.apply_active_battle_win_unlocks()
	_set_result_modal_for_win(win_result)
	end_screen.show()

func on_battle_lost() -> void:
	_set_result_modal(LOSE_TITLE, LOSE_HINT_DEFAULT)
	end_screen.show()

func _set_result_modal_for_win(win_result: Dictionary) -> void:
	var hint_text := WIN_HINT_DEFAULT
	
	var newly_unlocked: PackedStringArray = win_result.get("newly_unlocked", PackedStringArray())
	var is_new_clear := bool(win_result.get("is_new_clear", false))
	
	if not newly_unlocked.is_empty():
		hint_text = "New character unlocked: %s\nChoose what to do next." % ", ".join(newly_unlocked)
	elif is_new_clear:
		hint_text = "Stage cleared.\nChoose what to do next."
	_set_result_modal(WIN_TITLE, hint_text)

func _set_result_modal(title_text: String, hint_text: String) -> void:
	result_title.text = title_text
	result_hint.text = hint_text

func _on_pause_resume_requested() -> void:
	pause_modal.close_menu()

func _on_pause_exit_battle_requested() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(WORLD_SCENE)

func _on_pause_exit_game_requested() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)

func _on_result_retry_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_result_exit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)
