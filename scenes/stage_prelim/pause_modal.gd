extends CanvasLayer
class_name PauseModal

signal resume_requested
signal exit_battle_requested
signal exit_game_requested

enum ExitChoice {
	NONE,
	BATTLE,
	GAME
}

@onready var modal_root: Control = $ModalRoot
@onready var resume_button: Button = $ModalRoot/CenterContainer/Panel/VBoxContainer/Buttons/Resume
@onready var exit_battle_button: Button = $ModalRoot/CenterContainer/Panel/VBoxContainer/Buttons/ExitBattle
@onready var exit_game_button: Button = $ModalRoot/CenterContainer/Panel/VBoxContainer/Buttons/ExitGame
@onready var confirm_box: Control = $ModalRoot/ConfirmOverlay
@onready var confirm_text: Label = $ModalRoot/ConfirmOverlay/CenterContainer/ConfirmPanel/VBoxContainer/ConfirmText
@onready var confirm_yes_button: Button = $ModalRoot/ConfirmOverlay/CenterContainer/ConfirmPanel/VBoxContainer/ConfirmButtons/Yes
@onready var confirm_no_button: Button = $ModalRoot/ConfirmOverlay/CenterContainer/ConfirmPanel/VBoxContainer/ConfirmButtons/No
var pending_choice := ExitChoice.NONE

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	SFX.bind_button_sounds(self)
	SFX.use_decline_sound(confirm_no_button)
	modal_root.hide()
	_set_confirm_visible(false)

func open_menu() -> void:
	get_tree().paused = true
	SFX.play_pause()
	modal_root.show()
	pending_choice = ExitChoice.NONE
	_set_confirm_visible(false)
	resume_button.grab_focus()

func close_menu() -> void:
	modal_root.hide()
	pending_choice = ExitChoice.NONE
	_set_confirm_visible(false)
	SFX.play_unpause()
	get_tree().paused = false

func _unhandled_input(event: InputEvent) -> void:
	if not modal_root.visible:
		return
	if event.is_action_pressed("ui_cancel"):
		if confirm_box.visible:
			_on_no_pressed()
		else:
			resume_requested.emit()
		get_viewport().set_input_as_handled()

func _on_resume_pressed() -> void:
	resume_requested.emit()

func _on_exit_battle_pressed() -> void:
	pending_choice = ExitChoice.BATTLE
	confirm_text.text = "Exit this battle and return to map?"
	_set_confirm_visible(true)
	confirm_yes_button.grab_focus()

func _on_exit_game_pressed() -> void:
	pending_choice = ExitChoice.GAME
	confirm_text.text = "Exit to main menu?"
	_set_confirm_visible(true)
	confirm_yes_button.grab_focus()

func _on_yes_pressed() -> void:
	match pending_choice:
		ExitChoice.BATTLE:
			exit_battle_requested.emit()
		ExitChoice.GAME:
			exit_game_requested.emit()
	pending_choice = ExitChoice.NONE

func _on_no_pressed() -> void:
	var last_choice := pending_choice
	pending_choice = ExitChoice.NONE
	_set_confirm_visible(false)
	if last_choice == ExitChoice.BATTLE:
		exit_battle_button.grab_focus()
	else:
		exit_game_button.grab_focus()

func _set_confirm_visible(confirm_visible: bool) -> void:
	confirm_box.visible = confirm_visible
