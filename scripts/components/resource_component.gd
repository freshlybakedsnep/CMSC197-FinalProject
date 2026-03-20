@tool
extends EntityComponent
class_name ResourceComponent

func _init() -> void:
	type = Type.RESOURCE

signal resource_changed(current: int, max_val: int)

@export var res_name : String
@export var max_amount : int = 5
@export var start_amount : int = 0
@export var turn_regen : int = 1

var current_amount : int

func initialize() -> void:
	current_amount = start_amount

func consume(amount: int) -> void:
	if current_amount >= amount:
		current_amount -= amount
		resource_changed.emit(current_amount, max_amount)

func gain(amount: int) -> void:
	current_amount = clamp(current_amount + amount, -1, max_amount)
	resource_changed.emit(current_amount, max_amount)

func on_turn_start() -> void:
	if turn_regen != 0:
		gain(turn_regen)
