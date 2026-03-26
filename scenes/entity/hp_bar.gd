extends Node2D
class_name HPBar

signal finished

@onready var main_bar: ProgressBar = $HealthBar
@onready var ghost_bar: ProgressBar = $GhostBar
@onready var preview_bar: ProgressBar = $PreviewBar

var _tween : Tween

func _ready() -> void:
	hide()

func initialize(current: float, maximum: float) -> void:
	main_bar.max_value = maximum
	ghost_bar.max_value = maximum
	preview_bar.max_value = maximum
	
	main_bar.value = current
	ghost_bar.value = current
	preview_bar.value = current

func update(current: float, maximum: float) -> void:
	show()
	ghost_bar.show()
	main_bar.max_value = maximum
	ghost_bar.max_value = maximum
	preview_bar.max_value = maximum
	
	preview_bar.value = current
	
	if _tween: _tween.kill()
	_tween = create_tween()
	_tween.set_parallel(false)
	_tween.tween_interval(0.2)
	if current < main_bar.value:
		main_bar.value = current
		_tween.tween_property(ghost_bar, "value", current, 0.4).set_trans(Tween.TRANS_SINE)
	else:
		ghost_bar.value = current
		_tween.tween_property(main_bar, "value", current, 0.4).set_trans(Tween.TRANS_SINE)
	
	_tween.tween_interval(0.5)
	_tween.tween_callback(func(): 
		hide()
		finished.emit())

func reset() -> void:
	preview_bar.value = main_bar.value

func update_prediction(amount: int) -> void:
	var current = main_bar.value
	preview_bar.max_value = main_bar.max_value
	preview_bar.value = clamp(current + amount, 0, main_bar.max_value)

func display_prediction() -> void:
	ghost_bar.hide()
	if preview_bar.value < main_bar.value:
		preview_bar.modulate = Color(0.973, 0.929, 0.082, 1.0)
		main_bar.modulate.a = 0.5
	else:
		preview_bar.modulate = Color(0.553, 0.98, 0.69, 1.0)
		main_bar.modulate.a = 1.0
	preview_bar.show()

func clear_prediction() -> void:
	preview_bar.hide()
	ghost_bar.show()
	main_bar.modulate.a = 1.0
