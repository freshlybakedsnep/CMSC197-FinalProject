@abstract
extends Resource
class_name ValueFormula

var level := 0

func set_level(val: int) -> void:
	level = val - 1

@abstract func calculate(src : EntityData, tar : EntityData) -> float
