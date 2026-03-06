@tool
extends Resource
class_name Ability

var downtime : int = 0

@export var ability_name : String
@export var ability_level : int = 1:
	set(value):
		ability_level = clamp(value, 1, 5)
		notify_property_list_changed()
@export var ability_icon : Texture = preload("res://assets/icon_test.png")

@export var target_group := TargetGroup.SELF:
	set(value):
		target_group = value
		notify_property_list_changed()
enum TargetGroup {SELF, ALLY_ONLY, PARTY, ENEMY}

@export var target_mode : TargetMode :
	set(value):
		target_mode = value
		notify_property_list_changed()
enum TargetMode {SINGLE, AOE, RANDOM, MULTIPLE}
@export var target_count := 1

const additional : Array[StringName] = [&"mode"]

@export var basic_ability := false :
	set(value):
		basic_ability = value
		notify_property_list_changed()
@export var cooldown : int
@export var cost : int
@export var effects : Array[EffectGroup]

var enemies : Array
var heroes : Array

func _validate_property(property: Dictionary) -> void:
	if property.name in ["target_mode", "cooldown", "cost", "target_count"]:
		var hide = false
		match property.name:
			"target_mode":
				hide = target_group == TargetGroup.SELF
			"cooldown", "cost":
				hide = basic_ability == true
			"target_count":
				hide = (target_mode == TargetMode.AOE or
						target_mode == TargetMode.SINGLE or 
						target_group == TargetGroup.SELF)
		if hide:
			property.usage &= ~PROPERTY_USAGE_EDITOR
		else:
			property.usage |= PROPERTY_USAGE_EDITOR

func cast(src: Entity) -> void:
	lock_entities(src)
	if target_mode == TargetMode.RANDOM:
		src.set_target(random(src.current_target))
	
	for fx in effects:
		var targets = finalize_targets(src, fx)
		await fx.trigger(src, targets, ability_level)
	downtime = cooldown + 1

func lock_entities(src: Entity) -> void:
	var tree = src.get_tree()
	enemies = tree.get_nodes_in_group("enemies").filter(func(x): return x is Entity)
	heroes = tree.get_nodes_in_group("heroes").filter(func(x): return x is Entity)
	
	enemies = enemies.filter(func(x): return is_instance_valid(x) and x.data.state > 0)
	heroes = heroes.filter(func(x): return is_instance_valid(x) and x.data.state > 0)

func determine_targets(src: Entity, variant) -> Array[Entity]:
	var out : Array
	
	match variant.target_group:
		TargetGroup.ENEMY:
			out = enemies if src is Hero else heroes
		TargetGroup.SELF:
			out = [src]
		_:
			out = heroes if src is Hero else enemies
			if variant.target_group == TargetGroup.ALLY_ONLY:
				out.erase(src)
	
	var targets : Array[Entity]
	for o in out:
		targets.append(o as Entity)
	return targets

func finalize_targets(src: Entity, fg: EffectGroup) -> Array[Entity]:
	if fg.inherit_targets:
		if not src.current_target.is_empty():
			return src.current_target
	
	var pool: Array[Entity] = determine_targets(src, fg)
	match fg.target_mode:
		TargetMode.AOE:
			return pool
		TargetMode.SINGLE:
			if src.current_target.size() > 0:
				return [src.current_target[0]]
			return pool.pick_random()
		TargetMode.RANDOM:
			return random(pool)
		TargetMode.MULTIPLE:
			return src.current_target
	return []

func random(pool: Array[Entity]) -> Array[Entity]:
	pool.shuffle()
	return pool.slice(0, min(pool.size(), target_count))
