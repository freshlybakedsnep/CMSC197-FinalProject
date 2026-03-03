extends Node
class_name Stage

signal turn_changed()

@export var entity : PackedScene
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

func _ready() -> void:
	heroes.setup(actor_finished, eliminated)
	enemies.setup(actor_finished, eliminated)
	command_ui.connect_formations(enemies.formation, heroes.formation.values().filter(func(f): return f))
	start_battle()

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
		func(h): return h.data.stats["HEALTH"] <= 0
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
		
	turn_queue.sort_custom(
		func(a, b) : return a.data.stats["SPEED"] > b.data.stats["SPEED"])

func start_battle() -> void:
	load_next_wave()
	start_turn()

func start_turn() -> void:
	turn_count += 1
	enemies.fill_vacancies()
	
	for e in get_tree().get_nodes_in_group("entities"):
		if (e as Entity).data.state == UnitData.State.NORMAL:
			e.new_turn()
	
	update_turn_order()
	print("\nTurn %d" % turn_count)
	turn_changed.emit()

func start_fight() -> void:
	RenderingServer.global_shader_parameter_set("screen_dim_amount", 0.3)
	for ent in turn_queue:
		if ent is Hero:
			if (ent as Hero).action == HeroData.ActionMode.GUARD_ATTACK:
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
	
	if enemies.has_vacancies() >= 5 or turn_queue.is_empty():
		end_turn()
		return
	
	var actor : Entity = turn_queue.pop_front()
	if actor.data.state == UnitData.State.NORMAL:
		actor.highlight_me(true)
		actor.outline_me(true)
		acted.append(actor)
		actor.do_action()
	else:
		next_actor()

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
		
		if ent is Enemy:
			enemies.remove_from_formation(ent)
			print(ent.name, " is deleted")
			ent.queue_free()
		else:
			ent.data.state = UnitData.State.DEAD
		ent.remove_from_group("entities")
