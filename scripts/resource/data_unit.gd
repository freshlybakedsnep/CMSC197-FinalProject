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
enum State {DEAD, NORMAL}

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

var resistance : DefenseState
enum DefenseState {NORMAL, GUARD, INVINCIBLE, ABSORB}

func calculate_hit(incoming: float, attacker_el: ElementalType, bypass: bool = false) -> Dictionary:
	var type_mult: float = 1.0
	if TypeChart.has(attacker_el):
		type_mult = TypeChart[elemental_type].get(attacker_el, 1.0)
	var def_mult: float = 1.0
	
	match resistance:
		DefenseState.GUARD:
			def_mult *= 0.75
		DefenseState.ABSORB:
			def_mult *= -1.0
		DefenseState.INVINCIBLE:
			if !bypass:
				def_mult *= 0.0
		
	var final_dmg = incoming * type_mult * def_mult
	
	return {
		"result": int(final_dmg),
		"type_mult": type_mult,
		"resistance": resistance
	}

func calculate_heal(incoming: float) -> Dictionary:
	var final_heal = incoming
	
	if stats.has("HEAL_MOD"):
		final_heal *= stats["HEAL_MOD"]
	
	return {
		"result": int(final_heal),
		"type_mult": 1.0,
		"resistance": resistance
	}

func modify_stat(stat_name : StringName, value : int) -> void:
	stats[stat_name] = stats[stat_name] + value
	if stat_name == "HEALTH_MAX":
		health_changed.emit(stats["HEALTH"], stats["HEALTH_MAX"])
		if value > 0:
			modify_stat("HEALTH", value)
	if stat_name == "HEALTH":
		stats["HEALTH"] = clamp(stats["HEALTH"], 0, stats["HEALTH_MAX"])
		health_changed.emit(stats["HEALTH"], stats["HEALTH_MAX"])

@abstract func reset_to_default() -> void

@abstract func get_ability() -> Ability
