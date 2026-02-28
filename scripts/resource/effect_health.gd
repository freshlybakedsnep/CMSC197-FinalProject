@tool
extends Effect
class_name HealthAdjust

# damage and healing effect
@export var is_damaging := true

func trigger(source : Entity, recipient : Entity) -> void:
	if !is_instance_valid(recipient):
		effect_finished.emit()
		return
	
	var output = formula.calculate(source, recipient) * (1 if is_damaging else -1)
	if is_damaging:
		var m = recipient.data.get_effectiveness(source.element)
		output *= m
		if recipient.current_action == UnitData.ActionMode.GUARD_ATTACK:
			output *= 0.5
		print("%s deals %d DMG to %s" % [source.name, int(output), recipient.name])
	else:
		print("%s recovers %d HP to %s" % [source.name, int(output), recipient.name])
	recipient.highlight_me(true)
	await recipient.modify_health(int(output), source.element, is_damaging)
	effect_finished.emit()
