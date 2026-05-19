extends CanvasLayer
class_name MapPauseModal

signal resume_requested
signal exit_to_menu_requested

@onready var modal_root: Control = $ModalRoot
@onready var resume_button: Button = $ModalRoot/CenterContainer/Panel/VBoxContainer/Buttons/Resume
@onready var exit_menu_button: Button = $ModalRoot/CenterContainer/Panel/VBoxContainer/Buttons/ExitToMenu
@onready var confirm_box: Control = $ModalRoot/ConfirmOverlay
@onready var confirm_yes_button: Button = $ModalRoot/ConfirmOverlay/CenterContainer/ConfirmPanel/VBoxContainer/ConfirmButtons/Yes
@onready var confirm_no_button: Button = $ModalRoot/ConfirmOverlay/CenterContainer/ConfirmPanel/VBoxContainer/ConfirmButtons/No

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
	_set_confirm_visible(false)
	resume_button.grab_focus()

func close_menu() -> void:
	modal_root.hide()
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

func _on_exit_to_menu_pressed() -> void:
	_set_confirm_visible(true)
	confirm_yes_button.grab_focus()

func _on_yes_pressed() -> void:
	exit_to_menu_requested.emit()

func _on_no_pressed() -> void:
	_set_confirm_visible(false)
	exit_menu_button.grab_focus()

func _set_confirm_visible(confirm_visible: bool) -> void:
	confirm_box.visible = confirm_visible
