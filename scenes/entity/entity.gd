@abstract
extends Area2D
class_name Entity

signal entity_action_over
signal entity_eliminated
signal dead

var damage_text : PackedScene = preload("res://scenes/ui/damage_text.tscn")
@onready var statuses: Node = $Statuses
@onready var hp_bar: HPBar = $HPBar
@onready var element_icon : TextureRect = $HPBar.get_child(0).get_child(0)
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var target_component: Button = $TargetComponent

var data : UnitData
var intent : Ability
var current_target : Array[Entity]

var model 

# depicts entity
@export var targetable := true

func _ready() -> void:
	data.health_changed.connect(hp_bar.update)
	
	input_event.connect(_on_input_event)
	
	target_component.focus_exited.connect(func():
			outline_me(false))
	target_component.focus_entered.connect(func():
			outline_me(true))
	mouse_entered.connect(func():
		if target_component.visible:
			target_component.grab_focus())
	mouse_exited.connect(func():
		if target_component.visible:
			target_component.release_focus())
	
	prepare_health_bar()
	position_health_bar()

func prepare_health_bar() -> void:
	element_icon.texture = load("res://assets/jobs/El%s.png" % str(data.stats["ELEMENT"]+1))
	if data is HeroData:
		element_icon.hide()

func position_health_bar():
	var frame_tex = sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)
	var sprite_height = frame_tex.get_size().y * sprite.scale.y
	hp_bar.position.y = -(sprite_height / 2)
	
	target_component.position.y = hp_bar.position.y

@abstract func setup(res : UnitData) -> void
@abstract func new_turn() -> void
@abstract func end_turn() -> void
@abstract func set_target() -> void

func do_action() -> void:
	print("%s uses %s" % [data.entity_name, intent.ability_name])
	await intent.take_effect(self, current_target)
	entity_action_over.emit()

func apply_status(status : StatusCondition, stat : StringName) -> void:
	var t = create_tween()
	t.tween_property(self, "modulate", Color(0.727, 0.55, 0.383, 1.0), 0.1)
	await t.finished
	t.stop()
	var x = create_tween()
	x.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.1 )
	#print("%s: %s" % [stat, data.stats[stat]])
	statuses.add_child(status)
	data.modify_stat(stat, status.value)
	#print("%s receives a %s" % [name, status.name])
	#print("%s: %s" % [stat, data.stats[stat]])

func modify_health(incoming : int, el : UnitData.ElementalType, 
	damaging : bool) -> void:
	data.modify_stat("HEALTH", -incoming)
	hp_bar.show()
	var t = damage_text.instantiate() as DamageText
	var m = data.get_effectiveness(el)
	t.amount(incoming, m, damaging)
	hp_bar.add_child(t)
	await t.finished

	if data.stats["HEALTH"] <= 0 and data.state > 0:
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

func highlight_me(enabled : bool) -> void:
	sprite.material.set_shader_parameter("is_bright", enabled)

func outline_me(enabled : bool) -> void:
	sprite.material.set_shader_parameter("active", enabled)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void: 
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT:
			print("%s: %d/%d" % [name, data.stats["HEALTH"], data.stats["HEALTH_MAX"]])
			if targetable and target_component.visible:
				target_component.pressed.emit()
