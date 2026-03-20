extends TextureRect
class_name Cursor

@export var menu_parent_path : NodePath
@export var cursor_offset : Vector2

func _process(_delta: float) -> void:
	var focused_node = get_viewport().gui_get_focus_owner()
	if focused_node is Control:
		var iposition = focused_node.global_position
		var isize = focused_node.size
		global_position = Vector2(
			iposition.x + ((isize.x + size.x) / 2.0), 
			iposition.y - size.y 
			) - cursor_offset
