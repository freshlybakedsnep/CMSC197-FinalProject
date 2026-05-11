extends Resource
class_name LocationData

@export var id: StringName
@export var display_name: String = ""
@export var background: Texture2D
@export var left_location: LocationData
@export var right_location: LocationData
@export_file("*.tres") var left_location_path: String = ""
@export_file("*.tres") var right_location_path: String = ""
@export var battle_nodes: Array[BattleNodeData] = []
@export var service_nodes: Array[ServiceNodeData] = []

func get_left_location() -> LocationData:
	if left_location != null:
		return left_location
	if left_location_path.is_empty():
		return null
	return load(left_location_path) as LocationData

func get_right_location() -> LocationData:
	if right_location != null:
		return right_location
	if right_location_path.is_empty():
		return null
	return load(right_location_path) as LocationData
