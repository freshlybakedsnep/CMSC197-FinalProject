@tool
extends Effect
class_name HealthAdjust

# damage and healing effect
@export_category("Health Alteration")
@export var is_damaging := true

func trigger(source : Entity, recipient : Entity) -> void:
	var base_power = formula.calculate(source.data, recipient.data)
	var result: Dictionary
	
	if is_damaging:
		result = recipient.data.calculate_hit(-base_power, source.data.stats["ELEMENT"])
	else:
		result = recipient.data.calculate_heal(base_power)
	
	recipient.highlight_me(true)
	await recipient.modify_health(result, is_damaging, false)
	effect_finished.emit()
