@abstract
extends Resource
class_name UnitData

signal health_changed(current : int, maximum : int)
const TypeChart = {
	ElementalType.FIRE : 	{ElementalType.WATER: 	2.0, 	ElementalType.WOOD: 	0.5},
	ElementalType.WATER : 	{ElementalType.WOOD: 	2.0, 	ElementalType.FIRE: 	0.5},
	ElementalType.WOOD : 	{ElementalType.FIRE: 	2.0, 	ElementalType.WATER: 	0.5},
	ElementalType.LIGHT : 	{ElementalType.DARK: 	2.0},
	ElementalType.DARK : 	{ElementalType.LIGHT: 	2.0}
}

var state : State 
enum State {DEAD, DOWN, NORMAL}

@export_category("Entity Information")
@export var entity_name := "Entity"
@export var character_model := PackedScene
@export var sprite : Texture

@export_group("Entity Kit")
@export var elemental_type : ElementalType
enum ElementalType { FIRE, WATER, WOOD, LIGHT, DARK}
@export var basic_atk : Array[Ability]
@export var skills : Array[Ability]
@export var ultimate : Array[Ability]

@export_group("Base Stats")
@export var base_health := 10
@export var base_attack := 4
@export var base_defense := 2
@export var base_speed := 5

var stats : Dictionary = {
	"HEALTH" : 0,
	"HEALTH_MAX" : 0,
	"ATTACK" : 0,
	"DEFENSE" : 0,
	"SPEED" : 0,
	"ELEMENT" : 0
}

func get_effectiveness(element : ElementalType) -> float:
	if TypeChart.has(element):
		return TypeChart[elemental_type].get(element, 1.0)
	return 0

func modify_stat(stat_name : StringName, value : int) -> void:
	stats[stat_name] = stats[stat_name] + value
	if stat_name == "HEALTH":
		stats["HEALTH"] = clamp(stats["HEALTH"], 0, stats["HEALTH_MAX"])
		health_changed.emit(stats["HEALTH"], stats["HEALTH_MAX"])

@abstract func reset_to_default() -> void

@abstract func get_ability() -> Ability
