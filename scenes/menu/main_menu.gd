extends Control

const INTRO_SCENE := "res://scenes/player_world/intro.tscn"
const WORLD_SCENE := "res://scenes/player_world/world.tscn"

@onready var continue_btn: Button = $CenterContainer/VBoxContainer/Continue

func _ready() -> void:
	continue_btn.disabled = not PartyManager.has_save()

func _on_new_game_pressed() -> void:
	PartyManager.reset_progress()
	get_tree().change_scene_to_file(INTRO_SCENE)

func _on_continue_pressed() -> void:
	PartyManager.load_progress()
	if PartyManager.intro_seen:
		get_tree().change_scene_to_file(WORLD_SCENE)
	else:
		get_tree().change_scene_to_file(INTRO_SCENE)

func _on_exit_pressed() -> void:
	get_tree().quit()
