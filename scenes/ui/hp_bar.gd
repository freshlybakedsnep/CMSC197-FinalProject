extends Node2D
class_name HPBar

signal finished
var _tween : Tween

func update(curr : float, maxh : float) -> void:
	if _tween:
		_tween.kill()
	
	_tween = create_tween()
	
	_tween.set_trans(Tween.TRANS_SINE)
	_tween.set_ease(Tween.EASE_OUT)
	
	if $HealthBar.max_value != maxh:
		_tween.tween_property($HealthBar, "max_value", maxh, 0.2)
	_tween.tween_property($HealthBar, "value", curr, 0.5)
	
	_tween.tween_interval(0.5)
	
	_tween.tween_callback(func(): 
		hide()
		finished.emit())
