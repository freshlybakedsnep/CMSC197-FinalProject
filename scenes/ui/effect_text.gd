extends Node2D
class_name EffectText
signal finished

@export var duration := 0.5
@export var travel_distance := 25

func _ready() -> void:
	var f = create_tween()
	f.tween_property(self, "position", Vector2(position.x, travel_distance), duration).set_ease(Tween.EASE_IN)
	await f.finished
	
	var f2 = create_tween()
	f2.tween_property(self, "scale", Vector2(0, 0), 0.1)
	await f2.finished
	finished.emit()
	queue_free()

func effect(text: String, color: Color, buff) -> void:
	modulate = color
	if buff:
		position = Vector2(position.x, travel_distance)
		travel_distance -= travel_distance
	$Label.text = text
