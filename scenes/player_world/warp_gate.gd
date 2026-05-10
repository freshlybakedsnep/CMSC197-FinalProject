extends Area2D

@export_file("*.tscn") var destination_path: String
@onready var sprite: Sprite2D = $Sprite2D

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Switch to the battle scene
		get_tree().change_scene_to_file(destination_path)
