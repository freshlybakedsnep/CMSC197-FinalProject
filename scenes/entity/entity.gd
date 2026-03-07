@abstract
extends Area2D
class_name Entity

signal entity_action_over
signal entity_eliminated
signal dead

var damage_text : PackedScene = preload("res://scenes/ui/damage_text.tscn")
var effect_text : PackedScene = preload("res://scenes/ui/effect_text.tscn")
@onready var statuses: Node = $Statuses
@onready var hp_bar: HPBar = $HPBar
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var target_component: Button = $TargetComponent

var data : UnitData
var intent : Ability
var current_target : Array[Entity]

var model 

# depicts entity
@export var targetable := true

func _ready() -> void:
	hp_bar.initialize(data.stats["HEALTH"], data.stats["HEALTH_MAX"])
	data.health_changed.connect(hp_bar.update)
	
	input_event.connect(_on_input_event)
	mouse_entered.connect(func():
		if target_component.visible:
			target_component.grab_focus())
	mouse_exited.connect(func():
		if target_component.visible:
			target_component.release_focus())
	
	position_health_bar()

func position_health_bar():
	var frame_tex = sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)
	var sprite_height = frame_tex.get_size().y * sprite.scale.y
	hp_bar.position.y = -(sprite_height / 2)
	target_component.position.y = hp_bar.position.y

@abstract func setup(res : UnitData) -> void
@abstract func new_turn() -> void
@abstract func end_turn() -> void
@abstract func set_target(entity) -> void

func do_action() -> void:
	print("%s uses %s" % [data.entity_name, intent.ability_name])
	await intent.cast(self)
	entity_action_over.emit()

func apply_status(status : StatusCondition, stat : StringName) -> void:
	var tw = effect_text.instantiate() as EffectText
	tw.effect(status.stat, status.is_buff)
	add_child(tw)
	var t = create_tween()
	var c : Color
	if status.is_buff:
		c = Color(1.0, 0.816, 0.502, 1.0)
	else:
		c = Color(0.596, 0.784, 0.851, 1.0)
	
	t.tween_property(self, "modulate", c, 0.1)
	await t.finished
	t.stop()
	var x = create_tween()
	x.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.1 )
	#print("%s: %s" % [stat, data.stats[stat]])
	statuses.add_child(status)
	data.modify_stat(stat, status.value)
	#print("%s receives a %s" % [name, status.name])
	#print("%s: %s" % [stat, data.stats[stat]])

func modify_health(hit_data: Dictionary, damaging: bool, pierce: bool) -> void:
	data.modify_stat("HEALTH", hit_data["result"])
	var t = damage_text.instantiate() as DamageText
	t.modify(hit_data, damaging, pierce)
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
