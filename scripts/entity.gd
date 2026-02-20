extends Node
class_name Entity

signal entity_action_over
signal entity_eliminated
signal entity_selected

var data : UnitData

var element : UnitData.ElementalType
var health : int
var health_max : int
var attack : int
var defense : int
var speed : int

var targetable := true
var target_range : Array[Entity]
var current_target : Array[Entity]
var action : Ability

var is_hero : bool

# hero units only
var current_action : UnitData.ActionMode
var hud = null

# enemy units only
var charge := 0

@onready var sprite: AnimatedSprite2D = $Sprite

var element_icon : TextureRect
var hp_bar_hud : Control
var hp_bar : ProgressBar

@onready var target_component: Node2D = $TargetComponent

func update_health_bar() -> void:
	if hp_bar != null:
		hp_bar.max_value = health_max
		hp_bar.value = health

func prepare_health_bar() -> void:
	if !is_hero:
		hp_bar_hud = $EnemyHPBar
		element_icon = hp_bar_hud.get_child(0)
		hp_bar = $EnemyHPBar.get_child(1)
		
		element_icon.texture = load("res://assets/jobs/El%s.png" % str(element+1))
		position_health_bar()
		
	update_health_bar()

func position_health_bar():
	var frame_tex = sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)
	var sprite_height = frame_tex.get_size().y * sprite.scale.y
	
	hp_bar_hud.position.y = -(sprite_height / 2)
	hp_bar_hud.position.x = -(hp_bar_hud.size.x / 2)

func _ready() -> void:
	target_component.connect("has_focus", highlight_me)
	prepare_health_bar()

func setup(res : UnitData):
	data = res
	is_hero = res is HeroData
	
	element = data.elemental_type
	name = data.entity_name
	
	health_max = data.health_max
	health = data.health
	
	attack = data.attack
	defense = data.defense
	speed = data.speed

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

func target_viable(target : Entity) -> bool:
	if target is Object and !is_instance_valid(target):
		return false
	if target.is_queued_for_deletion():
		return false
	return true

func do_action() -> void:
	if action.mode == Ability.TargetMode.SINGLE:
		var target : Entity
		if target_viable(current_target[0]):
			target = current_target[0]
		else:
			target_range.erase(current_target[0])
			for candidate in target_range:
				if target_viable(candidate):
					target = candidate
					break
		if target != null:
			action.take_effect(self, target)
	else:
		for target in current_target:
			if target_viable(target):
				action.take_effect(self, target)
	entity_action_over.emit()

func modify_health(
	incoming : int, 
	el : UnitData.ElementalType, 
	damaging : bool
	) -> void:
	if damaging:
		incoming *= data.get_effectiveness(el)
		if current_action == UnitData.ActionMode.GUARD_ATTACK:
			incoming *= 0.5
	health = max(0, health - ceil(incoming))
	update_health_bar()
	
	if health <= 0:
		eliminated()
	
	if hud != null:
		hud.health_bar.update_health(health)

func eliminated() -> void:
	print(name + " has died!")
	entity_eliminated.emit(self)
	if !is_hero:
		self.queue_free()
	else:
		data.state = UnitData.State.DOWN

func end_turn() -> void:
	if !is_hero:
		charge = (charge + 1) % (data.max_charges + 1)
	action = null
	current_target.clear()
	target_range.clear()

func highlight_me(enabled : bool) -> void:
	sprite.material.set_shader_parameter("active", enabled)
