extends EntityFormation
class_name EnemyFormation

var enemy_pool : Array[EnemyData]
var names : Dictionary[String, int]

var _vacancies := 5

func load_wave(new_wave : Array[EnemyData]) -> void:
	enemy_pool = new_wave.duplicate()
	names.clear()

func fill_vacancies() -> void:
	while _vacancies > 0 and not enemy_pool.is_empty():
		var enemy_res = enemy_pool.pop_front() as EnemyData
		if enemy_res == null : return
		
		enemy_res = enemy_res.duplicate(true)
		enemy_res.initialize()
		
		if names.keys().has(enemy_res.entity_name):
			names[enemy_res.entity_name] += 1
			enemy_res.entity_name += " " + char(64 + names[enemy_res.entity_name])
		else:
			names[enemy_res.entity_name] = 1
		
		var enemy_node = spawn_entity(enemy_res, false)
		enemy_node.add_to_group("enemies")
		probe_and_position(enemy_node, enemy_res.starting_position)

func is_wave_clear() -> bool:
	return _vacancies == 5 and enemy_pool.is_empty()

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
