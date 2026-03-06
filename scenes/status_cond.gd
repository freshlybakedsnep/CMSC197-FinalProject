extends Node
class_name StatusCondition

var host : Entity = null
var value := 0
var stat : StringName
var is_buff := true
var is_removable := true
var is_permanent := false
var duration := 0
var hit_based := false
var hits := 0

func setup(data: Dictionary) -> void:
	for attr in data:
		if attr in self:
			self.set(attr, data[attr])

func reduce_duration() -> void:
	if is_permanent: return
	duration -= 1
	if duration <= 0: 
		remove()
		queue_free()

func reduce_hits() -> void:
	if hit_based: return
	hits -= 1
	if hits <= 0: 
		remove()
		queue_free()

func remove() -> void:
	if !is_removable: return
	host.data.modify_stat(stat, -value) 
