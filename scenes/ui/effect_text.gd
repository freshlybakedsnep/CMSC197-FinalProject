extends Node2D
class_name EffectText
signal finished

@export var duration := 0.5
@export var travel_distance := 25

@export var buff_color : Color
@export var dbff_color : Color

func _ready() -> void:
	var f = create_tween()
	f.tween_property(self, "position", Vector2(position.x, travel_distance), duration).set_ease(Tween.EASE_IN)
	await f.finished
	
	var f2 = create_tween()
	f2.tween_property(self, "scale", Vector2(0, 0), 0.1)
	await f2.finished
	finished.emit()
	queue_free()

func effect(x: String, b: bool) -> void:
	if b:
		modulate = buff_color
		position = Vector2(position.x, travel_distance)
		travel_distance -= travel_distance
		x += " Up!"
	else:
		modulate = dbff_color
		x += " Down!"
	$Label.text = x
