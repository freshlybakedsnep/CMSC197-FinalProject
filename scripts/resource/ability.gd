@tool
extends Resource
class_name Ability

@export var ability_name : String
@export var ability_level : int = 1:
	set(value):
		ability_level = clamp(value, 1, 5)
		notify_property_list_changed()

@export var target := TargetGroup.SELF:
	set(value):
		target = value
		notify_property_list_changed()
enum TargetGroup {SELF, ALLY_ONLY, PARTY, ENEMY}

@export var mode : TargetMode
enum TargetMode {SINGLE, AOE, RANDOM}

const additional : Array[StringName] = [&"mode"]

@export var basic_ability := false :
	set(value):
		basic_ability = value
		notify_property_list_changed()
@export var cooldown : int
@export var cost : int
@export var effects : Array[Effect]

func _validate_property(property: Dictionary) -> void:
	var hide = false
	match property.name:
		"mode":
			hide = target == TargetGroup.SELF
		"cooldown", "cost":
			hide = basic_ability == true
	
	if hide:
		property.usage &= ~PROPERTY_USAGE_EDITOR
	else:
		property.usage |= PROPERTY_USAGE_EDITOR

func take_effect(source : Entity, recipient : Entity) -> void:
	for fx in effects:
		fx.formula.set_level(ability_level)
		var side : Array[Entity]
		var target_range : Array[Entity]
		
		if !fx.inherit_target:	
			side.assign(source.get_tree().get_nodes_in_group(
				"heroes" if source.is_hero else "enemies").filter(
			func(x): return (is_instance_valid(x) and x.data.state > 0)))
			match fx.target_group:
				Ability.TargetGroup.SELF:
					target_range.append(source)
				Ability.TargetGroup.ENEMY:
					target_range.assign(source.get_tree().get_nodes_in_group("enemies" if source.is_hero else "heroes").filter(
					func(x): return (is_instance_valid(x) and x.data.state > 0)))
				_:
					if fx.target_group == TargetGroup.ALLY_ONLY:
						side.erase(source)
					target_range.assign(side)
			print(target_range)
			print(fx.target_mode)
			
			match fx.target_mode: 
				Ability.TargetMode.AOE:
					var targets_hit := 0
					for ent in target_range:
						targets_hit += 1
						fx.trigger(source, ent)
					for i in range(targets_hit):
						await fx.effect_finished
				Ability.TargetMode.RANDOM:
					await fx.trigger(source, target_range.pick_random())
		else:
			await fx.trigger(source, recipient)
