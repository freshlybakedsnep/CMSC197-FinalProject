extends Node
class_name StatusCondition

var effect_text : PackedScene = preload("res://scenes/ui/effect_text.tscn")

var host: Entity = null
var icon: Texture = null
var description: String

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

func spawn_label(text: String, col: Color = Color.WHITE) -> void:
	var t = effect_text.instantiate() as EffectText
	t.effect(text, col, is_buff)
	host.add_child(t)
	await t.finished

func reduce_duration() -> void:
	if is_permanent: return
	duration -= 1
	if duration <= 0: expire()

func reduce_hits() -> void:
	if hit_based: return
	hits -= 1
	if hits <= 0: 
		expire()

func dispel() -> bool:
	if !is_removable: return false
	revert()
	queue_free()
	return true

func expire() -> void:
	revert()
	queue_free()

func apply() -> void:
	pass

func revert() -> void:
	pass
