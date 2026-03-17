@abstract
extends Resource
class_name Effect

@export var formula: ValueFormula

@abstract func get_effect_data(src: EntityData, tar: EntityData, level: int) -> Dictionary
