@tool
@abstract
extends Resource
class_name Effect

signal effect_finished

@export var formula : ValueFormula

@export_group("Targeting Settings")
@export var inherit_target : bool :
	set(value):
		inherit_target = value
		notify_property_list_changed()

@export var target_group : Ability.TargetGroup :
	set(value):
		target_group = value
		notify_property_list_changed()
@export var target_mode : Ability.TargetMode

func _validate_property(property: Dictionary) -> void:
	var hide = false
	match property.name:
		"target_group", "target_mode":
			hide = inherit_target
	
	if hide:
		property.usage &= ~PROPERTY_USAGE_DEFAULT
	else:
		property.usage |= PROPERTY_USAGE_DEFAULT

@abstract func trigger(source : Entity, recipient : Entity) -> void
