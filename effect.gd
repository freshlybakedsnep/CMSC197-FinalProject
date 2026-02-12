@abstract
class_name Effect
extends Resource

@export var formula : ValueFormula

func trigger(source : UnitData) -> void:
	var target = source.target
	
	if target is Array:
		for t in target:
			
			
			pass
	else:
		pass
	pass
