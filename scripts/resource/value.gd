@abstract
extends Resource
class_name ValueFormula

var level := 1

func set_level(val : int) -> void:
	level = val - 1

@abstract func calculate(src : UnitData, tar : UnitData) -> float
