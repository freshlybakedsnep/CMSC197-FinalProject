extends UnitData
class_name EnemyData

@export var max_charges := 5
@export var starting_charge := 0
var charge : int

@export var starting_position := Positions.ANY
enum Positions {
	ANY,
	POSITION1,
	POSITION2,
	POSITION3,
	POSITION4,
	POSITION5
}

func reset_to_default() -> void:
	stats["HEALTH"] = base_health
	stats["HEALTH_MAX"] = base_health
	stats["ATTACK"] = base_attack
	stats["DEFENSE"] = base_defense
	stats["SPEED"] = base_speed
	stats["ELEMENT"] = elemental_type
	stats["CHARGE"] = starting_charge
	
	state = State.NORMAL

func get_ability() -> Ability:
	if stats["CHARGE"] >= max_charges:
		return ultimate[0]
	else:
		var actions = []
		actions.append_array(basic_atk)
		actions.append_array(skills)
		return actions.pick_random()
