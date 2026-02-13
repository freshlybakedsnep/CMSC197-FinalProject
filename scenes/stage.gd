extends Node
class_name StageInfo

@export var waves : Array[Wave]
@onready var battle_ui: Control = $BattleUI

@export var entity : PackedScene

const MAX_ON_FIELD := 5

var on_field : Dictionary = {
	1 : null,
	2 : null,
	3 : null,
	4 : null,
	5 : null
}

var current_wave_data : Wave
var max_waves := 1
var wave_index := 0
var turn_count := 0

var hero_nodes : Array[Entity]


var turn_queue : Array
var acted : Array
var names : Dictionary

func _ready() -> void:
	max_waves = waves.size()
	spawn_party()
	start_battle()

func spawn_entity(res : UnitData) -> Node:
	var node = entity.instantiate()
	add_child(node)
	
	node.add_to_group("heroes" if res is HeroData else "enemies")
	node.setup(res)
	return node

func spawn_party() -> void:
	for i in PartyManager.party.size():
		var hero_res = PartyManager.party[i]
		if hero_res == null: continue
		hero_nodes.append(spawn_entity(hero_res))

func start_battle() -> void:
	current_wave_data = waves[wave_index].duplicate(true)
	battle_ui.battle_start(hero_nodes)
	start_turn()

func start_turn() -> void:
	initialize_enemy_formation()
	for e in get_tree().get_nodes_in_group("entities"):
		e.new_turn()
	
	update_turn_order()
	turn_count += 1
	start_phase_plan()

func initialize_enemy_formation() -> void:
	var f = 1
	var e = MAX_ON_FIELD
	
	while e > 0:
		var enemy_res = current_wave_data.enemies.pop_front()
		if enemy_res == null : return
		
		enemy_res = enemy_res.duplicate()
		
		if names.keys().has(enemy_res.entity_name):
			names[enemy_res.entity_name] += 1
			enemy_res.entity_name += " " + char(64 + names[enemy_res.entity_name])
		else:
			names[enemy_res.entity_name] = 1
		
		var enemy_node = spawn_entity(enemy_res)
		
		var scouting = true
		if enemy_res.starting_position != EnemyData.Positions.ANY:
			var s = enemy_res.starting_position
			if on_field.get(s) == null:
				on_field[s] = enemy_node
				scouting = false
		if scouting:
			while on_field.get(f):
				f += 1
			on_field[f] = enemy_node
			f += 1
		
		e -= 1

func update_turn_order() -> void:
	turn_queue.clear()
	
	for unit in get_tree().get_nodes_in_group("entities"):
		if not acted.has(unit):
			turn_queue.append(unit)
	
	turn_queue.sort_custom(
		func(a, b) : return a.speed > b.speed
	)

func start_phase_plan():
	print("Turn %d" % turn_count)
	battle_ui.turn_start(on_field)

func end_turn():
	acted.clear()
	
	if (current_wave_data.enemies.size() <= 0 and 
	on_field.values().all(func(x): return x == null)):
		wave_index += 1
		if wave_index > max_waves:
			print("Stage Clear!")
			return
		current_wave_data = waves[wave_index].duplicate(true)
	start_turn()

func start_phase_fight() -> void:
	while turn_queue:
		enact(turn_queue.pop_front())
	end_turn()

func enact(actor : Entity) -> void:
	var f = []
	for e in actor.current_target:
		f.append(e.name)
	f = ", ".join(f)
	
	#var t = actor.current_target
	#if t == null or (t is Object and is_instance_valid(t)):
		## retarget logic
		#pass
	print("%s uses %s on %s" % 
	[actor.name, actor.action.ability_name, f])
	
	acted.append(actor)
	
	actor.current_action = UnitData.ActionMode.NONE
	actor.action = null
	actor.current_target.clear()
	actor.target_range.clear()
	
	update_turn_order()
