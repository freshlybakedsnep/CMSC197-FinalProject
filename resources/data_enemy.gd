extends UnitData
class_name EnemyData

@export var max_charges := 5
var charge := 0

@export var starting_position := Positions.ANY
enum Positions {
	POSITION1,
	POSITION2,
	POSITION3,
	POSITION4,
	POSITION5,
	ANY
}

func set_action() -> void:
	if charge >= max_charges:
		action = ActionMode.SKILL_EXTRA
	else:
		var acts = [1]
		if skill_use:
			acts.append(3)
		action = acts.pick_random() as ActionMode

func set_target() -> void:
	if get_current_ability().mode == Ability.TargetMode.AOE:
		target = target_range
	else:
		while true:
			var candidate = target_range.pick_random()
			if candidate.targetable == false:
				target_range.erase(candidate)
			else:
				target = candidate
				break

func get_current_ability():
	match action:
		UnitData.ActionMode.BASIC_ATTACK:
			return basic_atk[randi_range(0, basic_atk.size()-1)]
		UnitData.ActionMode.SKILL_EXTRA:
			return skill_ult[randi_range(0, skill_ult.size()-1)]
		_:
			return skill_use[randi_range(0, skill_use.size()-1)]
