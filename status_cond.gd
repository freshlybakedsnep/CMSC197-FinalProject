extends Node
class_name StatusCondition

var duration := 0
var hits := 0
var is_removable := true
var is_permanent := false
var hit_based := false
var stat : StringName

var host : Entity = null

var value := 0

func setup(val : int, target : Entity, stat_name : StringName) -> void:
	value = val
	host = target
	stat = stat_name

func set_duration(amount : int = 1) -> void:
	is_permanent = true
	duration = amount

func set_hits(amount : int = 1) -> void:
	hit_based = true
	hits = amount

func reduce_duration() -> void:
	if !is_permanent: return
	duration -= 1
	if duration <= 0: queue_free()

func reduce_hits() -> void:
	if !hit_based: return
	hits -= 1
	if hits <= 0: queue_free()

func apply() -> void:
	pass

func remove() -> void:
	if !is_removable: return
	pass
