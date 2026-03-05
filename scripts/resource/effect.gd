@tool
@abstract
extends Resource
class_name Effect

signal effect_finished

@export var formula : ValueFormula
@abstract func trigger(source : Entity, recipient : Entity) -> void
