extends Area2D
class_name Entity

signal entity_action_over
signal entity_eliminated
signal dead

@onready var statuses: Node = $Statuses

var damage_text : PackedScene = preload("res://scenes/ui/damage_text.tscn")
@onready var hp_bar: HPBar = $HPBar
@onready var element_icon : TextureRect = $HPBar.get_child(0).get_child(0)
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var target_component: TargetProxy = $TargetComponent
# will handle character animations 
var model 

# everything related to attributes
var data : UnitData
var is_hero : bool

# depicts entity
@export var targetable := true
var current_target : Array[Entity]
var intent : Ability

func _ready() -> void:
	target_component.connect("has_focus", outline_me)
	data.health_changed.connect(hp_bar.update)
	prepare_health_bar()
	position_health_bar()

func prepare_health_bar() -> void:
	element_icon.texture = load("res://assets/jobs/El%s.png" % str(data.element+1))
	if is_hero:
		element_icon.hide()

func position_health_bar():
	var frame_tex = sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)
	var sprite_height = frame_tex.get_size().y * sprite.scale.y
	hp_bar.position.y = -(sprite_height / 2)

func setup(res : UnitData):
	data = res
	name = data.entity_name
	is_hero = res is HeroData
	
	if data.health <= 0:
		data.state = UnitData.State.DEAD

func new_turn() -> void:
	intent = null
	if !is_hero:
		intent = data.get_ability()
		set_target()
	else:
		data.action = UnitData.ActionMode.NONE

func set_target(unit : Entity = null) -> void:
	current_target.clear()
	if is_hero: 
		current_target.append(unit)
		return
		
	# enemy only
	intent.lock_sides(self)
	var valid_targets = intent.match_suitable_targets(self, intent.target)
	match intent.mode:
		Ability.TargetMode.AOE, Ability.TargetMode.RANDOM:
			current_target.assign(valid_targets)
		_: 
			while true:
				var p = valid_targets.pick_random()
				if p == null: break
				if p.targetable:
					current_target.append(p)
					break
				else:
					valid_targets.erase(p)

func set_intent(ability : UnitData.ActionMode) -> void:
	if is_hero:
		intent = (data as HeroData).ability_preset[ability]
		data.action = ability

func do_action() -> void:
	print("%s uses %s" % [data.entity_name, intent.ability_name])
	await intent.take_effect(self, current_target)
	entity_action_over.emit()

func apply_status(status : StatusCondition) -> void:
	status.add(status)

func modify_health(incoming : int, el : UnitData.ElementalType, 
	damaging : bool) -> void:
	data.health -= incoming
	hp_bar.show()
	var t = damage_text.instantiate() as DamageText
	var m = data.get_effectiveness(el)
	t.amount(incoming, m, damaging)
	hp_bar.add_child(t)
	await t.finished

	if data.health <= 0 and data.state > 0:
		data.state = UnitData.State.DEAD
		entity_eliminated.emit()
		print(data.entity_name, " has died")

func die() -> void:
	# place death animation here
	# temporary
	var t : Tween = create_tween()
	t.tween_property(sprite, "self_modulate:a", 0.0, 0.6)
	await t.finished
	dead.emit()

func end_turn() -> void:
	if !is_hero:
		data.charge = (data.charge + 1) % (data.max_charges + 1)
	else:
		(data as HeroData).tick_abilities()
	intent = null
	current_target.clear()

func highlight_me(enabled : bool) -> void:
	sprite.material.set_shader_parameter("is_bright", enabled)

func outline_me(enabled : bool) -> void:
	sprite.material.set_shader_parameter("active", enabled)
