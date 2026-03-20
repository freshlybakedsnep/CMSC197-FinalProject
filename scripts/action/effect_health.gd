extends Effect
class_name HealthEffect

@export var is_damaging := true
@export var ignore_def := false
@export var piercing := false

func get_effect_data(src: EntityData, tar: EntityData, level: int) -> Dictionary:
	formula.set_level(level)
	return {
		"type": "HEALTH",
		"amount": formula.calculate(src, tar),
		"is_damaging": is_damaging,
		"ignore_def": ignore_def,
		"piercing": piercing
	}
