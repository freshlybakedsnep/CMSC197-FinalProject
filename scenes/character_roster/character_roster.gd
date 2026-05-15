extends Node2D

const ROSTER_DIR := "res://resources/character_roster/"
const COLS := 4
const H_SPACING := 320.0
const V_SPACING := 300.0
const START_POS := Vector2(220, 220)

@export var next_scene: PackedScene

@onready var characters_root: Node2D = $Characters
@onready var status_label: Label = $CanvasLayer/UI/Status
@onready var start_button: Button = $CanvasLayer/UI/StartBattle

func _ready() -> void:
	build_roster()
	start_button.disabled = next_scene == null

func build_roster() -> void:
	for child in characters_root.get_children():
		child.queue_free()

	var profiles: Array[Resource] = _load_profiles()
	if profiles.is_empty():
		status_label.text = "No roster files found at %s" % ROSTER_DIR
		return

	for i in profiles.size():
		var p := profiles[i]
		var card := _create_card(p)
		var col := i % COLS
		var row: float = floor(float(i) / float(COLS))
		card.position = START_POS + Vector2(col * H_SPACING, row * V_SPACING)
		characters_root.add_child(card)

	status_label.text = "Loaded %d characters from .tres" % profiles.size()

func _load_profiles() -> Array[Resource]:
	var result: Array[Resource] = []
	var dir := DirAccess.open(ROSTER_DIR)
	if dir == null:
		return result

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			var path := ROSTER_DIR + file_name
			var res := ResourceLoader.load(path)
			if res != null and res.has_method("get"):
				result.append(res)
		file_name = dir.get_next()

	result.sort_custom(func(a: Resource, b: Resource) -> bool:
		return str(a.get("character_name")) < str(b.get("character_name")))
	return result

func _create_card(profile: Resource) -> Node2D:
	var root := Node2D.new()
	var char_name := str(profile.get("character_name"))
	var role := int(profile.get("role"))
	var gender := int(profile.get("gender"))
	var sprite_tex := profile.get("sprite") as Texture2D
	root.name = char_name

	var frame := ColorRect.new()
	frame.color = _role_color(role)
	frame.position = Vector2(-110, -120)
	frame.size = Vector2(220, 260)
	frame.modulate.a = 0.2
	root.add_child(frame)

	var sprite := Sprite2D.new()
	sprite.texture = sprite_tex
	sprite.scale = Vector2(0.52, 0.52)
	root.add_child(sprite)

	var name_label := Label.new()
	name_label.text = char_name
	name_label.position = Vector2(-108, 142)
	name_label.size = Vector2(260, 24)
	root.add_child(name_label)

	var meta_label := Label.new()
	meta_label.text = "%s | %s" % [_role_to_text(role), _gender_to_text(gender)]
	meta_label.position = Vector2(-108, 168)
	meta_label.size = Vector2(280, 24)
	root.add_child(meta_label)

	return root

func _role_to_text(role: int) -> String:
	match role:
		0:
			return "Duelist"
		1:
			return "Juggernaut"
		2:
			return "Healer"
		3:
			return "Tactician"
		4:
			return "Vandal"
		_:
			return "Unknown"

func _gender_to_text(gender: int) -> String:
	match gender:
		0:
			return "Male"
		1:
			return "Female"
		_:
			return "Unknown"

func _role_color(role: int) -> Color:
	match role:
		0:
			return Color(0.95, 0.35, 0.25)
		1:
			return Color(0.50, 0.45, 0.85)
		2:
			return Color(0.20, 0.75, 0.35)
		3:
			return Color(0.15, 0.65, 0.90)
		4:
			return Color(0.95, 0.75, 0.20)
		_:
			return Color(1, 1, 1)

func _on_start_battle_pressed() -> void:
	if next_scene:
		get_tree().change_scene_to_packed(next_scene)
