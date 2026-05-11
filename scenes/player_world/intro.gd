extends Control

const WORLD_SCENE := "res://scenes/player_world/world.tscn"
var lines := [
	"You made it. The rifts opened and everything changed.",
	"I'm Lyra, a Duelist. I'll guide your first mission.",
	"Pick a gate, choose your party, then fight by turn order.",
	"Win battles to earn rewards and unlock stronger paths.",
	"I'll join your team now."
]
var idx := 0

@onready var dialogue: Label = $Dialogue

func _ready() -> void:
	if PartyManager.intro_seen:
		get_tree().change_scene_to_file(WORLD_SCENE)
		return
	_show_line()

func _on_next_pressed() -> void:
	idx += 1
	if idx >= lines.size():
		PartyManager.unlock_hero("Lyra")
		PartyManager.intro_seen = true
		PartyManager.save_progress()
		get_tree().change_scene_to_file(WORLD_SCENE)
		return
	_show_line()

func _on_skip_pressed() -> void:
	PartyManager.unlock_hero("Lyra")
	PartyManager.intro_seen = true
	PartyManager.save_progress()
	get_tree().change_scene_to_file(WORLD_SCENE)

func _show_line() -> void:
	dialogue.text = lines[idx]
