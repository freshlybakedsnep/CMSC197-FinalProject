extends Node

var heroes : Array[EntityData] = []
var enemies : Array[EntityData] = []
var _data_node : Dictionary = {}

func register_entity(data: EntityData, node: Entity, is_hero: bool) -> void:
	_data_node[data] = node
	var side = heroes if is_hero else enemies
	if not side.has(data): side.append(data)

func unregister_entity(data: EntityData) -> void:
	heroes.erase(data)
	enemies.erase(data)
	_data_node.erase(data)

func _prune_invalid_entities() -> void:
	for data in _data_node.keys():
		if not is_instance_valid(_data_node[data]):
			unregister_entity(data)

func clear_battle() -> void:
	heroes.clear()
	enemies.clear()
	_data_node.clear()

func get_potential_targets(src: EntityData, group_type: Action.TargetGroup) -> Array[EntityData]:
	_prune_invalid_entities()
	match group_type:
		Action.TargetGroup.SELF:
			return [src]
		Action.TargetGroup.ALLY_ONLY, Action.TargetGroup.PARTY:
			var side = heroes if _is_hero(src) else enemies
			side = side.duplicate()
			if group_type == Action.TargetGroup.ALLY_ONLY:
				side.erase(src)
			return side
		Action.TargetGroup.ENEMY:
			return enemies if _is_hero(src) else heroes
	return []

func _is_hero(data: EntityData) -> bool:
	_prune_invalid_entities()
	return heroes.has(data)

func get_entity(data: EntityData) -> Entity:
	if _data_node.has(data):
		var node = _data_node[data]
		if is_instance_valid(node):
			return node
		unregister_entity(data)
	return null
