extends Entity
class_name Enemy

func setup(res : UnitData) -> void:
	data = (res as EnemyData)
	name = data.entity_name

func new_turn() -> void:
	intent = data.get_ability()
	set_target()

func end_turn() -> void:
	data.stats["CHARGE"] = (data.stats["CHARGE"] + 1) % ((data as EnemyData).max_charges + 1)
	for stat in statuses.get_children():
		(stat as StatusCondition).reduce_duration()
	
func set_target() -> void:
	current_target.clear()
	intent.lock_sides(self)
	var valid_targets = intent.match_suitable_targets(self, intent.target)
	
	match intent.mode:
		Ability.TargetMode.AOE, Ability.TargetMode.RANDOM:
			current_target.assign(valid_targets)
		_: 
			while true:
				var p = valid_targets.pick_random()
				if p == null: break
				if p.targetable:
					current_target.append(p)
					break
				else:
					valid_targets.erase(p)
