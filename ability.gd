@tool
extends Resource
class_name Ability

@export var ability_name : String

@export var target := TargetGroup.SELF:
	set(value):
		target = value
		notify_property_list_changed()
enum TargetGroup {
	SELF,
	ALLY_ONLY,
	PARTY,
	ENEMY,
}

@export var mode : TargetMode
enum TargetMode {
	NONE,
	SINGLE,
	AOE,
	RANDOM
}

const additional : Array[StringName] = [&"mode"]

@export var cooldown : int
@export var cost : int
@export var effects : Array[Effect]

func _validate_property(property: Dictionary) -> void:
	if property.name in additional:
		if target == TargetGroup.SELF:
			property.usage = PROPERTY_USAGE_NO_EDITOR
		else:
			property.usage = PROPERTY_USAGE_DEFAULT

func take_effect(source : UnitData) -> void:
	for fx in effects:
		fx.trigger(source)
