extends Node
class_name Entity

@export var character_data : UnitData
var data : UnitData

var health : int
var health_max : int
var attack : int
var defense : int
var speed : int

var condition : UnitData.State
var targetable := true
var target_range : Array[Entity]
var current_target : Array[Entity]

var action : Ability

var is_hero : bool

# hero units only
var current_action : UnitData.ActionMode

# enemy units only
var charge := 0

func setup(res : UnitData):
	character_data = res
	data = character_data.duplicate()
	
	name = data.entity_name
	
	health_max = data.base_health
	health = health_max
	attack = data.base_attack
	defense = data.base_defense
	speed = data.base_speed
	is_hero = character_data is HeroData

func new_turn() -> void:
	action = null
	if !is_hero:
		charge += 1 % (data.max_charges + 1)
		get_ability()
		#print("%s is using %s" % [name, action.ability_name])
		set_target_range()
		set_target()
	else:
		current_action = UnitData.ActionMode.NONE

func set_target_range() -> void:
	target_range.clear()
	var side = get_tree().get_nodes_in_group("heroes" if is_hero else "enemies")
	if action == null: return
	
	match action.target:
		Ability.TargetGroup.SELF:
			target_range.append(self)
		Ability.TargetGroup.PARTY:
			target_range.assign(side)
		Ability.TargetGroup.ALLY_ONLY:
			side.erase(self)
			target_range.assign(side)
		Ability.TargetGroup.ENEMY:
			target_range.assign(get_tree().get_nodes_in_group("enemies" if is_hero else "heroes"))

func set_target(unit : Entity = null) -> void:
	current_target.clear()
	if is_hero: 
		current_target.append(unit)
		return
	
	# enemy only
	match action.mode:
		Ability.TargetMode.SINGLE:
			# attempt to get a target, if can't then they dont have target
			while true:
				var p = target_range.pick_random()
				if p == null: break
				if p.targetable:
					current_target.append(p)
					break
				else:
					target_range.erase(p)
		_: 
			current_target.assign(target_range)

func get_ability() -> Ability:
	action = data.get_ability(self)
	return action
