extends Node2D

@export var start_location: LocationData
@export var gate_scene: PackedScene
@export var player_level: int = 1 # replace later with your real progression source

@onready var background: Sprite2D = $Background
@onready var gates: Node2D = $Gates
@onready var left_arrow: Area2D = $LeftArrow
@onready var right_arrow: Area2D = $RightArrow

var current_location: LocationData

func _ready() -> void:
	BGM.play_world()
	current_location = start_location
	_render_location()

func _render_location() -> void:
	if current_location == null:
		return
		
	if current_location.background:
		background.texture = current_location.background
		_fit_background_to_viewport()
	
	for c in gates.get_children():
		c.queue_free()
	
	for b in current_location.battle_nodes:
		if b == null:
			continue
		if player_level < b.min_level:
			continue
		var gate = gate_scene.instantiate()
		gate.position = b.world_pos
		gate.location_name = b.label
		gate.destination_scene = b.battle_scene
		gates.add_child(gate)
	
	for s in current_location.service_nodes:
		if s == null:
			continue
		var gate = gate_scene.instantiate()
		gate.position = s.world_pos
		gate.location_name = s.label
		gate.destination_scene = s.target_scene
		gates.add_child(gate)
	
	left_arrow.visible = current_location.get_left_location() != null
	right_arrow.visible = current_location.get_right_location() != null

func _on_left_arrow_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var next_left := current_location.get_left_location()
		if next_left:
			current_location = next_left
			_render_location()

func _on_right_arrow_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var next_right := current_location.get_right_location()
		if next_right:
			current_location = next_right
			_render_location()

func _fit_background_to_viewport() -> void:
	if background.texture == null:
		return
	var vp := get_viewport_rect().size
	var ts := background.texture.get_size()
	background.position = vp * 0.5
	background.scale = Vector2(vp.x / ts.x, vp.y / ts.y)
