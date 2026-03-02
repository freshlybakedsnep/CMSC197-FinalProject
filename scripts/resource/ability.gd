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

func take_effect(source : Entity, recipient : Array[Entity]) -> void:
	for fx in effects:
		fx.formula.set_level(ability_level)
		
		var final_targets : Array[Entity] 
		if fx.inherit_target:
			final_targets = recipient
		else:
			final_targets = _get_targets(source, fx)
		
		var triggers := 0
		for ent in final_targets:
			if is_instance_valid(ent):
				triggers += 1
				fx.trigger(source, ent)
		
		for i in range(triggers):
			await i

func _get_targets(source : Entity, fx: Effect) -> Array[Entity]:
	var tree = source.get_tree()
	var heroes = tree.get_nodes_in_group("heroes")
	var enemies = tree.get_nodes_in_group("enemies")
	
	var out : Array[Entity] = []
	match fx.target_group:
		TargetGroup.SELF:
			out = [source]
		TargetGroup.ENEMY:
			var l = enemies if source.is_hero else heroes
			out.assign(l.filter(func(x): return is_instance_valid(x) and x.data.state > 0))
		TargetGroup.PARTY, TargetGroup.ALLY_ONLY:
			var l = heroes if source.is_hero else enemies
			out.assign(l.filter(func(x): return is_instance_valid(x) and x.data.state > 0))
			if fx.target_group == TargetGroup.ALLY_ONLY:
				out.erase(source)
	
	match fx.target_mode:
		TargetMode.SINGLE:
			out = [out[0]]
		TargetMode.AOE:
			pass
		TargetMode.RANDOM:
			out = [out.pick_random()]
	
	return out
