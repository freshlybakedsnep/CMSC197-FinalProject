extends ValueFormula
class_name ValueScaling

@export var multiplier := 1.0
@export var mult_per_level := 0.05
@export var from_target := false

@export var stat_key : String = "ATK"

func calculate(src : EntityData, tar : EntityData) -> float:
	var unit := tar if from_target else src
	
	var stat_comp := unit.get_comp(EntityComponent.Type.STATS)
	if not stat_comp:
		push_error("Unit %s is missing StatComponent" % unit.entity_name)
		return 0.0
	
	var base_val = stat_comp.get_stat(stat_key)
	return base_val * (multiplier + (mult_per_level * level))
