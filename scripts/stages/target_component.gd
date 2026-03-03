extends Node2D
class_name TargetProxy
signal has_focus(bool)

@onready var entity : Entity = get_parent()
@onready var proxy: Button = $FocusProxy

var is_selectable := false

func grab_focus() -> void:
	if is_selectable:
		proxy.grab_focus()
		has_focus.emit(true)

func focus_lost() -> void:
	has_focus.emit(false)

func _on_entity_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT:
			print("%s: %d/%d" % [entity.data.entity_name, entity.data.health, entity.data.health_max])
			if entity.targetable:
				proxy.pressed.emit()
