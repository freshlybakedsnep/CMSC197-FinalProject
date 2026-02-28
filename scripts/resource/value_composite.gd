extends ValueFormula
class_name CompositeValues

@export var values : Array[ValueFormula]

func calculate(src : Entity, tar : Entity) -> float:
	var total = 0
	for v in values:
		total += v.calculate(src, tar)
	return total
