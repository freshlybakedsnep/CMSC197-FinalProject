extends Node
class_name Stage

signal turn_changed()

@onready var command_ui: BattleMenu = $CommandUI
@onready var enemies : EnemyFormation = $Enemies
@onready var heroes : HeroFormation = $Heroes
@onready var interval: Timer = $Interval

@export var stage_info : StageInfo

var current_phase: Phase
enum Phase {
	COMMAND,
	COMBAT,
	CONCLUDE
}

var current_wave : Array[EnemyData]
var current_wave_index := -1

var turn_count := 0
var turn_queue : Array[Entity]
var acted : Array[Entity]
var eliminated : Array[Entity]

func _ready() -> void:
	heroes.setup(actor_finished, eliminated)
	enemies.setup(actor_finished, eliminated)
	command_ui.connect_formations(enemies, heroes)
	start_battle()

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

func start_battle() -> void:
	load_next_wave()
	start_turn()

func start_turn() -> void:
	current_phase = Phase.COMMAND
	turn_count += 1
	$TurnCount.text = "Turn: " + str(turn_count)
	
	enemies.fill_vacancies()
	$EnemyCount.text = "Enemies Left: " + str(enemies.enemy_pool.size())
	
	for e in get_tree().get_nodes_in_group("entities"):
		if e.data.state == EntityData.State.NORMAL:
			e.new_turn()
			pass
	
	update_turn_order()
	print("\nTurn %d" % turn_count)
	turn_changed.emit()

func start_fight() -> void:
	current_phase = Phase.COMBAT
	
	RenderingServer.global_shader_parameter_set("screen_dim_amount", 0.3)
	next_actor()

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

func end_turn():
	current_phase = Phase.CONCLUDE
	RenderingServer.global_shader_parameter_set("screen_dim_amount", 1.0)
	acted.clear()
	
	if enemies.is_wave_clear():
		print("Wave Clear!")
		if !load_next_wave():
			# code to update data on party manager 
			print("Stage Clear!")
			return
	
	start_turn()

func next_actor() -> void:
	update_turn_order()
	
	if enemies.has_vacancies() >= 5 or turn_queue.is_empty():
		end_turn()
		return
	
	var actor : Entity = turn_queue.pop_front()
	if actor.data.state == EntityData.State.NORMAL:
		acted.append(actor)
		actor.highlight_me(true)
		actor.outline_me(true)
		# and any code to trigger any lingering/running effects
		
		var status : StatusComponent = actor.data.get_comp(EntityComponent.Type.STATUS)
		if status and status.is_incapacitated():
			print(actor.name + " is STUNNED! Skipping turn.")
			actor_finished()
			return
		
		var controller = actor.data.get_comp(EntityComponent.Type.CONTROLLER)
		var decision : Dictionary = controller.get_next_action()
		
		if not decision.is_empty():
			await ActionParser.execute(actor, decision["action"], decision["targets"])
		controller.clear_queue()
	else:
		next_actor()

func actor_finished() -> void:
	print("")
	interval.start()
	await interval.timeout
	await clear_the_dead()
	
	if heroes.wiped():
		print("Game Over!")
		return
	next_actor()

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
