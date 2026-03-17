extends Resource
class_name EffectGroup

@export var inherit_target : bool = false : 
	set(value):
		inherit_target = value
		notify_property_list_changed()

@export var target_group : Action.TargetGroup :
	set(value):
		target_group = value
		notify_property_list_changed()
@export var target_mode : Action.TargetMode :
	set(value):
		target_mode = value
		notify_property_list_changed()
@export var target_count := 1
@export var target_state : Action.TargetState

@export var effects : Array[Effect]

func _validate_property(property: Dictionary) -> void:
	if property.name in ["target_mode", "target_count", "target_state"]:
		var hide := false
		match property.name:
			"target_mode", "target_state":
				hide = target_group == Action.TargetGroup.SELF
			"target_count":
				hide = (target_mode == Action.TargetMode.AOE or
					target_mode == Action.TargetMode.SINGLE or 
					target_group == Action.TargetGroup.SELF)
		if hide:
			property.usage &= ~PROPERTY_USAGE_EDITOR
		else:
			property.usage |= PROPERTY_USAGE_EDITOR
