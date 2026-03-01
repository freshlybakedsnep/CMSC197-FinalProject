extends Node2D
class_name DamageText
signal finished

@export var duration := 0.5

func _ready() -> void:
	var f = create_tween().set_parallel()
	f.tween_property(self, "modulate:a", 0.0, duration)
	f.tween_property(self, "position", Vector2(position.x, -25), duration)
	await f.finished
	finished.emit()
	queue_free()

func amount(x : float, v : float, h : bool) -> void:
	$Label.text = str(int(abs(x)))
	if h:
		match v:
			2.0:
				modulate = Color(1.0, 0.678, 0.322, 1.0)
			0.5:
				modulate = Color(0.619, 0.711, 1.0, 1.0)
	else:
		modulate = Color(0.0, 0.898, 0.0, 1.0)
