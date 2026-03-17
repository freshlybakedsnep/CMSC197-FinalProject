extends ValueFormula
class_name ValueComposite

@export var values : Array[ValueFormula]

func calculate(src : EntityData, tar : EntityData) -> float:
	var total = 0
	for v: ValueFormula in values:
		if v == null: continue
		v.set_level(level)
		total += v.calculate(src, tar)
	return total
