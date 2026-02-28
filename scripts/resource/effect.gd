@tool
@abstract
extends Resource
class_name Effect

signal effect_finished

@export var inherit_target : bool :
	set(value):
		inherit_target = value
		self.notify_property_list_changed()

@export var target_mode : Ability.TargetMode
@export var target_group : Ability.TargetGroup
const additional : Array[StringName] = [&"target_mode", &"target_group"]

func _validate_property(property: Dictionary) -> void:
	if property.name in additional:
		if inherit_target == true:
			property.usage = PROPERTY_USAGE_NO_EDITOR
		else:
			property.usage = PROPERTY_USAGE_DEFAULT

@export var formula : ValueFormula

@abstract func trigger(source : Entity, recipient : Entity) -> void
