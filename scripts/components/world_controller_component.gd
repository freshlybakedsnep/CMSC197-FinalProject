extends Node2D

const MAIN_MENU_SCENE := "res://scenes/menu/main_menu.tscn"

@export var start_location: LocationData
@export var gate_scene: PackedScene
@export var player_level: int = 1 # replace later with your real progression source

@export var party_select : PackedScene
@export var stage : PackedScene

@onready var background: Sprite2D = $Background
@onready var gates: Node2D = $Gates
@onready var left_arrow: Area2D = $LeftArrow
@onready var right_arrow: Area2D = $RightArrow
@onready var pause_modal = $MapPauseModal
@onready var location_banner: Label = $LocationBanner/Label

var current_stage : StageInfo
var current_battle_node: BattleNodeData
var current_location: LocationData
var active_party_selector: PartySelector
var location_banner_tween: Tween

func _ready() -> void:
	BGM.play_world()
	pause_modal.resume_requested.connect(_on_pause_resume_requested)
	pause_modal.exit_to_menu_requested.connect(_on_pause_exit_to_menu_requested)
	current_location = start_location
	_render_location()

func _unhandled_input(event: InputEvent) -> void:
	if is_instance_valid(active_party_selector):
		return
	if event.is_action_pressed("ui_cancel"):
		if get_tree().paused:
			return
		pause_modal.open_menu()
		get_viewport().set_input_as_handled()

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
		if b.stage_info:
			gate.stage_select.connect(open_party_select_for_battle.bind(b))
		gate.position = b.world_pos
		gate.location_name = b.label
		gate.battle_id = String(b.battle_id) if not String(b.battle_id).is_empty() else b.label.to_lower().replace(" ", "_")
		gate.unlock_heroes_on_win = b.unlock_heroes
		gate.destination_scene = null if b.stage_info else b.battle_scene
		gates.add_child(gate)
	
	for s in current_location.service_nodes:
		if s == null:
			continue
		var gate = gate_scene.instantiate()
		gate.position = s.world_pos
		gate.location_name = s.label
		gate.battle_id = ""
		gate.unlock_heroes_on_win = PackedStringArray()
		gate.destination_scene = s.target_scene
		gates.add_child(gate)
	left_arrow.visible = current_location.get_left_location() != null
	right_arrow.visible = current_location.get_right_location() != null
	_show_location_banner()

func open_party_select_for_battle(battle_node: BattleNodeData) -> void:
	if battle_node == null or battle_node.stage_info == null:
		return
	var battle_id := String(battle_node.battle_id).strip_edges()
	if battle_id.is_empty():
		battle_id = battle_node.label.to_lower().replace(" ", "_")
	PartyManager.set_active_battle(battle_id, battle_node.label, battle_node.unlock_heroes)
	current_battle_node = battle_node
	open_party_select(battle_node.stage_info)

func open_party_select(stage_info: StageInfo) -> void:
	if is_instance_valid(active_party_selector):
		return
	var p = party_select.instantiate() as PartySelector
	current_stage = stage_info
	active_party_selector = p
	_set_world_clickables_enabled(false)
	add_child(p)
	p.party_finalized.connect(start_battle)
	p.tree_exited.connect(_on_party_select_closed)

func start_battle() -> void:
	var s = stage.instantiate() as Stage
	s.stage_info = current_stage
	if current_battle_node:
		s.battle_background = current_battle_node.background
		s.enemy_formation_position = current_battle_node.enemy_formation_position
		s.hero_formation_position = current_battle_node.hero_formation_position
	add_child(s)
	s.stage_quit.connect(reload_world)
	hide()

func reload_world() -> void:
	show()

func _on_party_select_closed() -> void:
	active_party_selector = null
	current_battle_node = null
	_set_world_clickables_enabled(true)

func _set_world_clickables_enabled(enabled: bool) -> void:
	left_arrow.input_pickable = enabled
	right_arrow.input_pickable = enabled
	for gate in gates.get_children():
		var clickable_gate := gate as CollisionObject2D
		if clickable_gate:
			clickable_gate.input_pickable = enabled

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

func _show_location_banner() -> void:
	if current_location == null:
		return
	if is_instance_valid(location_banner_tween):
		location_banner_tween.kill()
	location_banner.text = _get_location_display_name()
	location_banner.visible = true
	location_banner.modulate.a = 0.0
	location_banner_tween = create_tween()
	location_banner_tween.tween_property(location_banner, "modulate:a", 1.0, 0.25)
	location_banner_tween.tween_interval(1.0)
	location_banner_tween.tween_property(location_banner, "modulate:a", 0.0, 0.75)
	location_banner_tween.tween_callback(location_banner.hide)

func _get_location_display_name() -> String:
	var location_name := current_location.display_name.strip_edges()
	if not location_name.is_empty():
		return location_name
	location_name = String(current_location.id).strip_edges()
	if not location_name.is_empty():
		return location_name.capitalize()
	return "Unknown Location"

func _on_pause_resume_requested() -> void:
	pause_modal.close_menu()

func _on_pause_exit_to_menu_requested() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)
