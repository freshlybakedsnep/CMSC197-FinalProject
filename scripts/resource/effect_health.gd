@tool
extends Effect
class_name HealthAdjust

# damage and healing effect
@export_category("Health Alteration")
@export var is_damaging := true

func trigger(source : Entity, recipient : Entity) -> void:
	if !is_instance_valid(recipient):
		effect_finished.emit()
		return

	var output = formula.calculate(source.data, recipient.data) * (1 if is_damaging else -1)
	if is_damaging:
		var m = recipient.data.get_effectiveness(source.data.element)
		output *= m
		if recipient.current_action == UnitData.ActionMode.GUARD_ATTACK:
			output *= 0.5
		print("%s deals %d DMG to %s" % [source.data.entity_name, int(output), recipient.data.entity_name])
	else:
		print("%s recovers %d HP to %s" % [source.data.entity_name, int(abs(output)), recipient.data.entity_name])
	
	recipient.highlight_me(true)
	await recipient.modify_health(int(output), source.data.element, is_damaging)
	effect_finished.emit()
