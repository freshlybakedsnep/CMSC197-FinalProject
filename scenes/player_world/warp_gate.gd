extends Area2D

signal stage_select

@export var destination_scene: PackedScene
@export var location_name: String = "Location"
@export var battle_id: String = ""
@export var unlock_heroes_on_win: PackedStringArray = []
@export var hover_tint: Color = Color(1.35, 1.2, 0.8, 1.0)
@export var normal_tint: Color = Color(1.0, 0.98, 0.82, 1.0)
@export var hover_scale: Vector2 = Vector2(1.08, 1.08)

@onready var glow_aura: Sprite2D = $GlowAura
@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $Label

var _base_scale: Vector2
var _base_glow_scale: Vector2

func _ready() -> void:
	_base_scale = sprite.scale
	_base_glow_scale = glow_aura.scale
	sprite.modulate = normal_tint
	label.text = location_name
	label.visible = false
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	_start_attention_pulse()

func _start_attention_pulse() -> void:
	var tween := create_tween().set_loops()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(glow_aura, "scale", _base_glow_scale * 1.14, 0.75)
	tween.parallel().tween_property(glow_aura, "modulate:a", 0.18, 0.75)
	tween.tween_property(glow_aura, "scale", _base_glow_scale, 0.75)
	tween.parallel().tween_property(glow_aura, "modulate:a", 0.38, 0.75)

func _on_mouse_entered() -> void:
	sprite.modulate = hover_tint
	sprite.scale = _base_scale * hover_scale
	label.visible = true
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _on_mouse_exited() -> void:
	sprite.modulate = normal_tint
	sprite.scale = _base_scale
	label.visible = false
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if destination_scene:
			if battle_id.strip_edges().is_empty():
				PartyManager.clear_active_battle()
			else:
				PartyManager.set_active_battle(battle_id, location_name, unlock_heroes_on_win)
			get_tree().change_scene_to_packed(destination_scene)
			return
		stage_select.emit()
