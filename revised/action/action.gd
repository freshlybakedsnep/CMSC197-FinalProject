@tool
extends Resource
class_name Action

enum TargetGroup {SELF, ALLY_ONLY, PARTY, ENEMY}
enum TargetMode {SINGLE, MULTIPLE, AOE, RANDOM }
enum TargetState {ALIVE, DEAD, ANY}

@export var action_name : String
@export var action_icon : Texture

# basically whether this action should be prioritized in the action order
# in prep for abilities that need to take precedence or not
@export var priority : int = 0
@export var level : int
@export var target_group : TargetGroup:
	set(value):
		target_group = value
		notify_property_list_changed()

@export var target_mode : TargetMode:
	set(value):
		target_mode = value
		notify_property_list_changed()

@export var target_count : int = 1 : 
	set(value):
		target_count = clampi(value, 1, 5)
@export var cooldown : int
@export var cost : int

@export var target_state : TargetState = TargetState.ALIVE

@export var effect_groups : Array[EffectGroup]

func _validate_property(property: Dictionary) -> void:
	if property.name in ["target_mode", "target_count", "target_state"]:
		var hide := false
		match property.name:
			"target_mode", "target_state":
				hide = target_group == TargetGroup.SELF
			"target_count":
				hide = (target_mode == TargetMode.AOE or
					target_mode == TargetMode.SINGLE or 
					target_group == TargetGroup.SELF)
		if hide:
			property.usage &= ~PROPERTY_USAGE_EDITOR
		else:
			property.usage |= PROPERTY_USAGE_EDITOR
