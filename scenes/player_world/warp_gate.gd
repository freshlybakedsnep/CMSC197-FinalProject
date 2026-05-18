extends Area2D

signal stage_select

@export var destination_scene: PackedScene
@export var location_name: String = "Location"
@export var battle_id: String = ""
@export var unlock_heroes_on_win: PackedStringArray = []
@export var hover_tint: Color = Color(1.2, 1.2, 1.2, 1.0)
@export var normal_tint: Color = Color(1, 1, 1, 1)
@export var hover_scale: Vector2 = Vector2(1.08, 1.08)

@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $Label

var _base_scale: Vector2

func _ready() -> void:
	_base_scale = sprite.scale
	label.text = location_name
	label.visible = false
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

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
