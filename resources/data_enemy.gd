extends UnitData
class_name EnemyData

@export var max_charges := 5

@export var starting_position := Positions.ANY
enum Positions {
	ANY,
	POSITION1,
	POSITION2,
	POSITION3,
	POSITION4,
	POSITION5
}

func get_ability(_actor : Entity = null):
	if _actor.charge >= max_charges:
		return ultimate[0]
	else:
		var actions = []
		actions.append_array(basic_atk)
		actions.append_array(skills)
		return actions.pick_random()
