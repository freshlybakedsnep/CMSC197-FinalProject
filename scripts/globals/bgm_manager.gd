extends Node
class_name BGMManager

const MENU_BGM_PATH := "res://assets/audio/bgm/1555699_Internubes-AIM-2026.mp3"
const WORLD_BGM_PATH := "res://assets/audio/bgm/1555699_Internubes-AIM-2026.mp3"
const BATTLE_BGM_PATH := "res://assets/audio/bgm/1564182_Tokyo-Map-SMT-Raidou-X-Ove.mp3"

var _player := AudioStreamPlayer.new()
var _current_path := ""

func _ready() -> void:
	add_child(_player)
	_player.name = "BGMPlayer"
	_player.volume_db = -30.0
	_player.finished.connect(_on_track_finished)

func play_menu() -> void:
	_play_path(MENU_BGM_PATH)

func play_world() -> void:
	_play_path(WORLD_BGM_PATH)

func play_battle() -> void:
	_play_path(BATTLE_BGM_PATH)

func stop_music() -> void:
	_current_path = ""
	_player.stop()

func set_volume_db(v: float) -> void:
	_player.volume_db = v

func _play_path(path: String) -> void:
	if path.is_empty():
		return
	if _current_path == path and _player.playing:
		return

	var stream := load(path) as AudioStream
	if stream == null:
		push_warning("BGM not found: %s" % path)
		return

	_current_path = path
	_player.stream = stream
	_player.play()

func _on_track_finished() -> void:
	# Seamless fallback loop for streams that don't have import-loop enabled.
	if _current_path != "":
		_player.play()
