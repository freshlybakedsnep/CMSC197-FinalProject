extends Control

const INTRO_SCENE := "res://scenes/player_world/intro.tscn"
const WORLD_SCENE := "res://scenes/player_world/world.tscn"

@onready var continue_btn: Button = $CenterContainer/MarginContainer/Panel/Body/Buttons/Continue
@onready var new_btn: Button = $CenterContainer/MarginContainer/Panel/Body/Buttons/NewGame
@onready var title_label: Label = $CenterContainer/MarginContainer/Panel/Body/Title
@onready var glow: ColorRect = $Backdrop/Glow
@onready var hero_portrait: TextureRect = $Backdrop/HeroPortrait
@onready var confirm_overlay: Control = $ConfirmOverlay
@onready var confirm_yes_btn: Button = $ConfirmOverlay/CenterContainer/Panel/VBoxContainer/Buttons/Yes
@onready var confirm_no_btn: Button = $ConfirmOverlay/CenterContainer/Panel/VBoxContainer/Buttons/No

func _ready() -> void:
	BGM.play_menu()
	SFX.bind_button_sounds(self)
	SFX.use_decline_sound(confirm_no_btn)
	continue_btn.disabled = not PartyManager.has_save()
	new_btn.grab_focus()
	confirm_overlay.visible = false

	if continue_btn.disabled:
		continue_btn.tooltip_text = "No save data found yet."

	_start_menu_motion()

func _start_menu_motion() -> void:
	# Keep title static in Y so it never overlaps the kicker.
	var title_tween := create_tween()
	title_tween.set_loops()
	title_tween.tween_property(title_label, "modulate:a", 0.88, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	title_tween.tween_property(title_label, "modulate:a", 1.0, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	var glow_tween := create_tween()
	glow_tween.set_loops()
	glow_tween.tween_property(glow, "modulate:a", 0.38, 2.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	glow_tween.tween_property(glow, "modulate:a", 0.18, 2.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	var portrait_tween := create_tween()
	portrait_tween.set_loops()
	portrait_tween.tween_property(hero_portrait, "position:y", 76.0, 3.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	portrait_tween.tween_property(hero_portrait, "position:y", 86.0, 3.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _on_new_game_pressed() -> void:
	confirm_overlay.visible = true
	confirm_yes_btn.grab_focus()

func _on_confirm_new_game_pressed() -> void:
	PartyManager.reset_progress()
	get_tree().change_scene_to_file(INTRO_SCENE)

func _on_cancel_new_game_pressed() -> void:
	confirm_overlay.visible = false
	new_btn.grab_focus()

func _on_continue_pressed() -> void:
	PartyManager.load_progress()
	if PartyManager.intro_seen:
		get_tree().change_scene_to_file(WORLD_SCENE)
	else:
		get_tree().change_scene_to_file(INTRO_SCENE)

func _on_exit_pressed() -> void:
	get_tree().quit()

func _unhandled_input(event: InputEvent) -> void:
	if confirm_overlay.visible and event.is_action_pressed("ui_cancel"):
		_on_cancel_new_game_pressed()
		get_viewport().set_input_as_handled()
