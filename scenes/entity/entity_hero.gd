extends Entity
class_name Hero

var action : HeroData.ActionMode

func setup(res : UnitData) -> void:
	data = (res as HeroData)
	name = data.entity_name

func new_turn() -> void:
	action = HeroData.ActionMode.NONE
	intent = null
	current_target.clear()

func end_turn() -> void:
	(data as HeroData).tick_abilities()
	for stat in statuses.get_children():
		(stat as StatusCondition).reduce_duration()

func set_intent(act : HeroData.ActionMode) -> void:
	intent = (data as HeroData).ability_preset[act]
	action = act

func set_target(entity : Array[Entity]) -> void:
	current_target.clear()
	current_target.append_array(entity)
