extends Node
@onready var bar: ProgressBar = $Bar
@onready var value: Label = $Value

func update_health(new_value : int, new_cap : int = 0) -> void:
	if new_cap:
		bar.max_value = new_cap
	bar.value = new_value
	value.text = str(new_value)
