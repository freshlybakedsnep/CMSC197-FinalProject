extends Node
class_name Stage

@export var entity : PackedScene
@onready var command_ui: Control = $CommandUI
@onready var enemies : EnemyManager = $Enemies
@onready var heroes : HeroManager = $Heroes
@onready var interval: Timer = $Interval

@export var stage_info : StageInfo
var current_wave : Array[EnemyData]
var current_wave_index := -1

var turn_count := 0
var turn_queue : Array
var acted : Array
var eliminated : Array[Entity]

func _ready() -> void:
	heroes.setup(spawn_entity)
	start_battle()

func spawn_entity(res : UnitData) -> Node:
	var node = entity.instantiate()
	
	node.add_to_group("heroes" if res is HeroData else "enemies")
	node.setup(res)
	node.connect("entity_action_over", actor_finished)
	node.connect("entity_eliminated", func(x): eliminated.append(x))
	return node

func load_next_wave() -> bool:
	current_wave_index += 1
	if current_wave_index >= stage_info.waves.size():
		return false
	
	print(current_wave_index + 1, "/", stage_info.waves.size())
	var curr_wave = stage_info.load_wave(current_wave_index)
	enemies.load_wave(curr_wave)
	return true

func party_wiped() -> bool:
	return get_tree().get_nodes_in_group("heroes").all(
		func(h): return h.data.health <= 0
	)

func update_turn_order() -> void:
	turn_queue.clear()
	for unit in get_tree().get_nodes_in_group("entities"):
		unit = unit as Entity
		unit.highlight_me(false)
		unit.outline_me(false)
		
		if (not is_instance_valid(unit) or 
			eliminated.has(unit) or 
			acted.has(unit) or 
			unit.data.state == UnitData.State.DEAD):
			continue
		turn_queue.append(unit)
		
	turn_queue.sort_custom(func(a, b) : return a.data.speed > b.data.speed)

func start_battle() -> void:
	load_next_wave()
	command_ui.battle_start(heroes.formation.values().filter(func(f): return f))
	start_turn()

func start_turn() -> void:
	turn_count += 1
	if enemies.has_vacancies():
		enemies.fill_vacancies(spawn_entity)
	
	for e in get_tree().get_nodes_in_group("entities"):
		e.new_turn()
	
	print(get_tree().get_nodes_in_group("heroes"))
	print(get_tree().get_nodes_in_group("enemies"))
	
	
	update_turn_order()
	start_phase_plan()

func start_phase_plan():
	print("\nTurn %d" % turn_count)
	command_ui.turn_start(enemies.formation)

func start_phase_fight() -> void:
	RenderingServer.global_shader_parameter_set("screen_dim_amount", 0.3)
	for ent in turn_queue:
		if ent.current_action == UnitData.ActionMode.GUARD_ATTACK:
			turn_queue.erase(ent)
			acted.append(ent)
	next_actor()

func end_turn():
	RenderingServer.global_shader_parameter_set("screen_dim_amount", 1.0)
	acted.clear()
	for e in get_tree().get_nodes_in_group("entities"):
		e.end_turn()
	
	if enemies.is_wave_clear():
		print("Wave Clear!")
		if !load_next_wave():
			# code to update data on party manager 
			print("Stage Clear!")
			return
	
	start_turn()

func next_actor() -> void:
	update_turn_order()
	var actor : Entity = turn_queue.pop_front()
	if actor: 
		
		if actor.data.state < 2:
			next_actor()
			return
		actor.highlight_me(true)
		actor.outline_me(true)
		acted.append(actor)
		actor.do_action()
	else:
		end_turn()

func actor_finished() -> void:
	print("")
	interval.start()
	await interval.timeout
	await clear_the_dead()
	
	if party_wiped():
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
		
		if !ent.is_hero:
			enemies.remove_from_formation(ent)
			print(ent.name, " is deleted")
			ent.queue_free()
		else:
			ent.data.state = UnitData.State.DOWN
		ent.remove_from_group("entities")
	eliminated.clear()
