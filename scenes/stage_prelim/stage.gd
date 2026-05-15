extends Node
class_name Stage

@onready var state_machine: GameStateMachine = $StateMachine

@onready var command_ui: BattleMenu = $CommandUI
@onready var enemies : EnemyFormation = $Enemies
@onready var heroes : HeroFormation = $Heroes
@onready var interval: Timer = $Interval

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
