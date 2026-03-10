@tool
extends Effect
class_name HealthAdjust

# damage and healing effect
@export_category("Health Alteration")
@export var is_damaging := true
@export var ignore_def := false
@export var piercing := false

func trigger(source : Entity, recipient : Entity) -> void:
	var base_power = formula.calculate(source.data, recipient.data)
	var result: Dictionary
	
	if is_damaging:
		piercing = piercing or recipient.data.flags["PIERCING"] > 0
		
		result = recipient.data.calculate_hit(
			-base_power, source.data.stats["ELEMENT"], piercing, ignore_def)
	else:
		result = recipient.data.calculate_heal(base_power)
	
	recipient.highlight_me(true)
	await recipient.modify_health(result, is_damaging, false)
	effect_finished.emit()
