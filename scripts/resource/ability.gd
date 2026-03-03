@tool
extends Resource
class_name Ability

@export var ability_name : String
@export var ability_level : int = 1:
	set(value):
		ability_level = clamp(value, 1, 5)
		notify_property_list_changed()
@export var ability_icon : Texture = preload("res://assets/icon_test.png")

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

var _heroes : Array[Entity]
var _enemies : Array[Entity]
var downtime : int = 0

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
	lock_sides(source)
	for fx in effects:
		fx.formula.set_level(ability_level)
		
		var final_targets : Array[Entity] 
		if fx.inherit_target:
			final_targets = recipient
			fx.target_mode = mode
		else: 
			final_targets = match_targets(source, fx, recipient)
		
		if fx.target_mode == TargetMode.AOE:
			for ent in final_targets:
				if is_instance_valid(ent):
					fx.trigger(source, ent)
			await source.get_tree().create_timer(0.6).timeout
		else:
			for ent in final_targets:
				if is_instance_valid(ent):
					await fx.trigger(source, ent)
	downtime = cooldown + 1

func lock_sides(source : Entity):
	var tree = source.get_tree()
	var enemies = tree.get_nodes_in_group("enemies").filter(func(x): return is_instance_valid(x) and x.data.state > 0) 
	var heroes = tree.get_nodes_in_group("heroes").filter(func(x): return is_instance_valid(x) and x.data.state > 0)
	
	_enemies.clear()
	_heroes.clear()
	for x in enemies:
		_enemies.append(x as Enemy)
	for y in heroes:
		_heroes.append(y as Hero)
	
func match_suitable_targets(source : Entity, tar : TargetGroup) -> Array[Entity]:
	var out : Array[Entity] = []
	match tar:
		TargetGroup.SELF:
			return [source]
		TargetGroup.ENEMY:
			out = _enemies if source is Hero else _heroes
		TargetGroup.PARTY, TargetGroup.ALLY_ONLY:
			out = _heroes if source is Hero else _enemies
			if tar == TargetGroup.ALLY_ONLY:
				out.erase(source)
	return out.filter(func(x): return is_instance_valid(x) and x.data.state > 0)
	
func match_targets(source : Entity, fx: Effect, recipient : Array [Entity]) -> Array[Entity]:
	var out : Array[Entity] = match_suitable_targets(source, fx.target_group)
	match fx.target_mode:
		TargetMode.SINGLE:
			if target == TargetMode.SINGLE:
				var x = recipient[0]
				if x.data.state > 0 and is_instance_valid(x):
					return recipient
			out = [out.pick_random()]
		TargetMode.RANDOM:
			out = [out.pick_random()]
	return out
