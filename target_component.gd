extends Node2D
signal has_focus(bool)

@onready var entity = get_parent()
@onready var proxy: Button = $FocusProxy

var is_selectable := false

func is_targetable(enabled : bool) -> void:
	if entity.hp_bar != null:
		entity.hp_bar_hud.visible = enabled

func grab_focus() -> void:
	if is_selectable:
		proxy.grab_focus()
		has_focus.emit(true)

func focus_lost() -> void:
	has_focus.emit(false)

func _on_entity_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT:
			print(entity.name, " has been clicked")
			if is_selectable:
				proxy.pressed.emit()
