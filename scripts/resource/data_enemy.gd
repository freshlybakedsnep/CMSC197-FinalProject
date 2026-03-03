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
	health_max = base_health
	health = health_max
	attack = base_attack
	defense = base_defense
	speed = base_speed
	element = elemental_type
	charge = starting_charge
	
	state = State.NORMAL

func get_ability(_act : ActionMode = ActionMode.NONE) -> Ability:
	if charge >= max_charges:
		return ultimate[0]
	else:
		var actions = []
		actions.append_array(basic_atk)
		actions.append_array(skills)
		return actions.pick_random()
