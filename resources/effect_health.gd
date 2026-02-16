@tool
extends Effect
class_name HealthAdjust

# damage and healing effect
@export var is_damaging := true

func trigger(source : Entity, recipient : Entity) -> void:
	#var amount = formula.calculate(source, recipient)
	#print("%s deals %d to %s" % [source, amount, recipient])
	#return
	var output = formula.calculate(source, recipient) * (1 if is_damaging else -1)
	recipient.modify_health(output, source.element, is_damaging)
