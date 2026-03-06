extends Node2D
class_name DamageText
signal finished

@export var duration := 0.5
@export var strong_color : Color
@export var weaker_color : Color
@export var heal_color : Color

func _ready() -> void:
	var f = create_tween()
	f.tween_property(self, "position", Vector2(position.x, -25), duration).set_ease(Tween.EASE_IN)
	await f.finished
	
	var f2 = create_tween()
	f2.tween_property(self, "scale", Vector2(0, 0), 0.1)
	await f2.finished
	finished.emit()
	queue_free()

func amount(x : float, v : float, h : bool) -> void:
	$Label.text = str(int(abs(x)))
	
	if h:
		match v:
			2.0: modulate = strong_color
			0.5: modulate = weaker_color
	else:
		modulate = heal_color

func effect(x: String, b: bool) -> void:
	$Label.text = x
	if b:
		modulate = Color(1.0, 0.678, 0.322, 1.0)
	else:
		modulate = Color(0.619, 0.711, 1.0, 1.0)
