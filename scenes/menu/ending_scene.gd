extends Control

const MAIN_MENU_SCENE := "res://scenes/menu/main_menu.tscn"
const WORLD_SCENE := "res://scenes/player_world/world.tscn"

@onready var credits_window: Control = $RootMargin/Body/CreditsPanel/CreditsWindow
@onready var credits_content: VBoxContainer = $RootMargin/Body/CreditsPanel/CreditsWindow/CreditsContent
@onready var main_menu_button: Button = $RootMargin/Body/Buttons/MainMenu
@onready var world_button: Button = $RootMargin/Body/Buttons/World

var credits_tween: Tween

func _ready() -> void:
	BGM.play_menu()
	SFX.bind_button_sounds(self)
	main_menu_button.grab_focus()
	_start_credit_roll()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and not _is_button_focused():
		_restart_credit_roll()
		get_viewport().set_input_as_handled()

func _start_credit_roll() -> void:
	await get_tree().process_frame
	var window_height := credits_window.size.y
	var content_height := credits_content.size.y
	credits_content.position.y = window_height
	
	credits_tween = create_tween()
	credits_tween.set_loops()
	credits_tween.tween_property(
		credits_content,
		"position:y",
		-content_height,
		max(14.0, content_height * 0.045)
	).set_trans(Tween.TRANS_LINEAR)
	credits_tween.tween_interval(1.0)
	credits_tween.tween_callback(func(): credits_content.position.y = window_height)

func _restart_credit_roll() -> void:
	if is_instance_valid(credits_tween):
		credits_tween.kill()
	_start_credit_roll()

func _is_button_focused() -> bool:
	return main_menu_button.has_focus() or world_button.has_focus()

func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)

func _on_world_pressed() -> void:
	get_tree().change_scene_to_file(WORLD_SCENE)
