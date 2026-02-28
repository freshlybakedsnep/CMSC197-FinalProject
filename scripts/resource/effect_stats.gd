@tool
extends Effect
class_name StatModify

# manipulate a stat of the target
@export var is_buff := true

func trigger(source : Entity, recipient : Entity) -> void:
	effect_finished.emit()
