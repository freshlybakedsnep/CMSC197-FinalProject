@tool
extends Resource
class_name EffectGroup

signal effect_finished

@export var inherit_targets : bool :
	set(value):
		inherit_targets = value
		notify_property_list_changed()
@export var target_group : Ability.TargetGroup :
	set(value):
		target_group = value
		notify_property_list_changed()
@export var target_mode : Ability.TargetMode
@export var effects : Array[Effect]

func _validate_property(property: Dictionary) -> void:
	var hide = false
	match property.name:
		"target_group", "target_mode":
			hide = inherit_targets
	
	if hide:
		property.usage &= ~PROPERTY_USAGE_DEFAULT
	else:
		property.usage |= PROPERTY_USAGE_DEFAULT

func trigger(src: Entity, targets: Array[Entity], level : int) -> void:
	for fx in effects:
		for t in targets:
			fx.formula.set_level(level)
			fx.trigger(src, t)
		await src.get_tree().create_timer(0.5).timeout
	
	effect_finished.emit()
