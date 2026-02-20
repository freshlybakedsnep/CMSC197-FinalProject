extends Node2D
class_name EnemyManager

var enemy_pool : Array[EnemyData]
var names : Dictionary[String, int]

@onready var pos1: Marker2D = $pos1
@onready var pos2: Marker2D = $pos2
@onready var pos3: Marker2D = $pos3
@onready var pos4: Marker2D = $pos4
@onready var pos5: Marker2D = $pos5

var formation : Dictionary[int, Entity] = {
	1: null, 2: null, 3: null, 4: null, 5: null
}

var _positions : Dictionary[int, Marker2D]

var _vacancies := 5

func _ready() -> void:
	_positions = {
		1: pos1,
		2: pos2,
		3: pos3,
		4: pos4,
		5: pos5
	}

func load_wave(new_wave : Array[EnemyData]) -> void:
	enemy_pool = new_wave.duplicate()
	names.clear()

func fill_vacancies(spawner : Callable) -> void:
	while _vacancies > 0 and not enemy_pool.is_empty():
		var enemy_res = enemy_pool.pop_front()
		if enemy_res == null : return
		
		enemy_res = enemy_res.duplicate()
		enemy_res.reset_to_default()
		
		if names.keys().has(enemy_res.entity_name):
			names[enemy_res.entity_name] += 1
			enemy_res.entity_name += " " + char(64 + names[enemy_res.entity_name])
		else:
			names[enemy_res.entity_name] = 1
		
		var enemy_node = spawner.call(enemy_res)
		probe_and_position(enemy_node, enemy_res.starting_position)

func is_wave_clear() -> bool:
	return _vacancies == 5 and enemy_pool.is_empty()

func has_vacancies() -> int:
	return _vacancies > 0

func add_to_formation(enemy : Entity, index : int, pos : Marker2D) -> void:
	formation[index] = enemy
	pos.add_child(enemy)
	_vacancies -= 1

func remove_from_formation(enemy : Entity) -> void:
	var x = formation.find_key(enemy)
	formation[x] = null
	_vacancies += 1

func probe_and_position(enemy: Entity, index : int) -> void:
	if index not in formation.keys():
		index = 1
	
	if formation[index] == null:
		add_to_formation(enemy, index, _positions[index])
	else:
		var other = formation.keys()
		other.erase(index)
		
		for f in other:
			if formation[f] == null: 
				add_to_formation(enemy, f, _positions[f])
				return
