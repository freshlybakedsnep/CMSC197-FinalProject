extends ValueFormula
class_name CompositeValues

@export var values : Array[ValueFormula]

func calculate(src : UnitData, tar : UnitData) -> float:
	var total = 0
	for v: ValueFormula in values:
		if v == null: continue
		v.set_level(level)
		total += v.calculate(src, tar)
	return total
