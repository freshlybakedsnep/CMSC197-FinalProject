extends TextureRect

const WORLD_SCENE := "res://scenes/player_world/world.tscn"
const INTRO_HERO_NAME := "Ares"

var intro_voice_lines: Array[AudioStream] = []
@onready var voice: AudioStreamPlayer = $Voice

var lines := [
	"You made it. The rifts opened and everything changed.",
	"I'm Ares, a Duelist. I'll guide your first mission.",
	"Pick a gate, choose your party, then fight by turn order.",
	"Win battles to earn rewards and unlock stronger paths.",
	"I'll join your team now."
]
var idx := 0

@onready var dialogue: Label = $Dialogue

func _ready() -> void:
	var hero := HeroDatabase.get_hero(INTRO_HERO_NAME)
	if hero:
		texture = hero.sprite
		if hero.intro_line_texts.size() > 0:
			lines = hero.intro_line_texts
		intro_voice_lines = hero.intro_voice_lines

	if PartyManager.intro_seen:
		_go_to_world()
		return
	_show_line()

func _show_line() -> void:
	dialogue.text = lines[idx]
	_play_line_voice(idx)

func _on_next_pressed() -> void:
	idx += 1
	if idx >= lines.size():
		PartyManager.unlock_hero(INTRO_HERO_NAME)
		PartyManager.intro_seen = true
		PartyManager.save_progress()
		_go_to_world()
		return
	_show_line()

func _on_skip_pressed() -> void:
	PartyManager.unlock_hero(INTRO_HERO_NAME)
	PartyManager.intro_seen = true
	PartyManager.save_progress()
	_go_to_world()

func _go_to_world() -> void:
	get_tree().call_deferred("change_scene_to_file", WORLD_SCENE)

func _play_line_voice(i: int) -> void:
	if voice.playing:
		voice.stop()
	if i >= 0 and i < intro_voice_lines.size() and intro_voice_lines[i] != null:
		voice.stream = intro_voice_lines[i]
		voice.play()
