extends Resource
class_name StageInfo

@export var waves : Array[Wave]
@export var exp_gain : float

func load_wave(active : int) -> Array[EnemyData]: 
	return waves[active].enemies
