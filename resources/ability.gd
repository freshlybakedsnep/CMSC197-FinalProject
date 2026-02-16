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

func take_effect(source : Entity, recipient : Entity) -> void:
	for fx in effects:
		if !fx.inherit_target:
			var side : Array[Entity]
			var target_range : Array[Entity]
			
			side.assign(source.get_tree().get_nodes_in_group("heroes" if source.is_hero else "enemies"))
			
			match fx.target_group:
				TargetGroup.SELF:
					target_range.append(source)
				TargetGroup.ALLY_ONLY:
					side.erase(source)
					target_range.assign(side)
				TargetGroup.ENEMY:
					target_range.assign(source.get_tree().get_nodes_in_group("enemies" if source.is_hero else "heroes"))
			
			match fx.target_mode:
				TargetMode.AOE:
					for ent in target_range:
						fx.trigger(source, ent)
				TargetMode.RANDOM:
					fx.trigger(source, target_range.pick_random())
		else:
			fx.trigger(source, recipient)
