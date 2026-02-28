extends Area2D
class_name Entity

signal entity_action_over
signal entity_eliminated
signal dead

var state : State
enum State {
	DEAD,
	DOWN,
	NORMAL,
}

var damage_text : PackedScene = preload("res://scenes/ui/damage_text.tscn")
@onready var hp_bar: HPBar = $HPBar
@onready var element_icon : TextureRect = $HPBar.get_child(0).get_child(0)
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var target_component: Node2D = $TargetComponent
# will handle character animations 
var model 

# everything related to attributes
var data : UnitData
var element : UnitData.ElementalType
var health : int
var health_max : int
var attack : int
var defense : int
var speed : int
var is_hero : bool

# depicts entity
@export var targetable := true
var target_range : Array[Entity]
var current_target : Array[Entity]
var action : Ability

# hero units only
var current_action : UnitData.ActionMode
var hud = null

# enemy units only
var charge := 0

func _ready() -> void:
	target_component.connect("has_focus", outline_me)
	prepare_health_bar()

func prepare_health_bar() -> void:
	hp_bar.update(health, health_max)
	element_icon.texture = load("res://assets/jobs/El%s.png" % str(element+1))
	if is_hero:
		element_icon.hide()
	position_health_bar()

func position_health_bar():
	var frame_tex = sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)
	var sprite_height = frame_tex.get_size().y * sprite.scale.y
	hp_bar.position.y = -(sprite_height / 2)

func setup(res : UnitData):
	state = State.NORMAL
	data = res
	is_hero = res is HeroData
	element = data.elemental_type
	name = data.entity_name
	health_max = data.health_max
	health = data.health
	attack = data.attack
	defense = data.defense
	speed = data.speed
	
	if health <= 0:
		state = State.DEAD

func new_turn() -> void:
	action = null
	if !is_hero:
		get_ability()
		set_target_range()
		set_target()
	else:
		current_action = UnitData.ActionMode.NONE

func set_target_range() -> void:
	target_range.clear()
	if action == null: return
	var side = get_tree().get_nodes_in_group(
		"heroes" if is_hero else "enemies").filter(
			func(x): return (is_instance_valid(x) and x.health > 0))
	
	match action.target:
		Ability.TargetGroup.SELF:
			target_range.append(self)
		Ability.TargetGroup.PARTY:
			target_range.assign(side)
		Ability.TargetGroup.ALLY_ONLY:
			side.erase(self)
			target_range.assign(side)
		Ability.TargetGroup.ENEMY:
			target_range.assign(
				get_tree().get_nodes_in_group(
					"enemies" if is_hero else "heroes").filter(
			func(x): return (is_instance_valid(x) and x.health > 0)))

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

func do_action() -> void:
	print("%s uses %s" % [name, action.ability_name])
	set_target_range()
	# action only has single target (aka, is targeted)
	if action.mode == Ability.TargetMode.SINGLE:
		var target : Entity = null
		# checks if the target is still valid (still in-battle)
		if current_target.size() > 0 and is_instance_valid(current_target[0]):
			if current_target[0].targetable:
				target = current_target[0]
		
		if target == null:
			if !is_hero:
				set_target()
			else:
				var fail_safe : Entity = null
				for candidate in target_range:
					if candidate.targetable:
						target = candidate
						break
					if fail_safe == null:
						fail_safe = candidate
				
				if target == null:
					target = fail_safe
		
		if target != null:
			await action.take_effect(self, target)
		# otherwise, do nothing
		
	else:
		var targets_hit := 0
		for target in current_target.filter(func(x): return is_instance_valid(x)):
			targets_hit += 1
			action.take_effect(self, target)
		for i in range(targets_hit):
			await i
	entity_action_over.emit()

func modify_health(incoming : int, el : UnitData.ElementalType, 
	damaging : bool) -> void:
	health = clamp(health - incoming, 0, health_max)
	hp_bar.update(health, health_max)
	hp_bar.show()
	if damaging:
		var t = damage_text.instantiate() as DamageText
		var m = data.get_effectiveness(el)
		t.amount(incoming, m)
		hp_bar.add_child(t)
		await t.finished

	if health <= 0 and state > 0:
		state = State.DEAD
		entity_eliminated.emit(self)
		print(name, " has died")
	
	if hud != null:
		hud.health_bar.update_health(health)

func die() -> void:
	# place death animation here
	# temporary
	var t : Tween = create_tween()
	t.tween_property(sprite, "self_modulate:a", 0.0, 0.6)
	await t.finished
	dead.emit()

func end_turn() -> void:
	if !is_hero:
		charge = (charge + 1) % (data.max_charges + 1)
	action = null
	current_target.clear()
	target_range.clear()

func highlight_me(enabled : bool) -> void:
	sprite.material.set_shader_parameter("is_bright", enabled)

func outline_me(enabled : bool) -> void:
	sprite.material.set_shader_parameter("active", enabled)
