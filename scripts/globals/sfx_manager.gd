extends Node
class_name SFXManager

const HOVER_PATH := "res://assets/audio/Menu_SFX/001_Hover_01.wav"
const CONFIRM_PATH := "res://assets/audio/Menu_SFX/013_Confirm_03.wav"
const DECLINE_PATH := "res://assets/audio/Menu_SFX/029_Decline_09.wav"
const DENIED_PATH := "res://assets/audio/Menu_SFX/033_Denied_03.wav"
const PAUSE_PATH := "res://assets/audio/Menu_SFX/092_Pause_04.wav"
const UNPAUSE_PATH := "res://assets/audio/Menu_SFX/098_Unpause_04.wav"
const BATTLE_START_PATH := "res://assets/audio/Battle_SFX/55_Encounter_02.wav"
const BATTLE_HIT_PATH := "res://assets/audio/Battle_SFX/15_Impact_flesh_02.wav"
const BATTLE_BLOCK_PATH := "res://assets/audio/Battle_SFX/39_Block_03.wav"
const BATTLE_DEATH_PATH := "res://assets/audio/Battle_SFX/69_Enemy_death_01.wav"
const HEAL_PATH := "res://assets/audio/Buffs_Heals_SFX/02_Heal_02.wav"
const BUFF_PATH := "res://assets/audio/Buffs_Heals_SFX/16_Atk_buff_04.wav"
const DEBUFF_PATH := "res://assets/audio/Buffs_Heals_SFX/21_Debuff_01.wav"
const DOT_PATH := "res://assets/audio/Atk_Magic_SFX/46_Poison_01.wav"

const POOL_SIZE := 6
const HOVER_COOLDOWN_MS := 70
const PRESS_SOUND_META := "sfx_press_path"

var _players: Array[AudioStreamPlayer] = []
var _cache: Dictionary = {}
var _last_hover_msec := 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in POOL_SIZE:
		var player := AudioStreamPlayer.new()
		player.name = "SFXPlayer%d" % (i + 1)
		player.volume_db = -20.0
		player.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(player)
		_players.append(player)
	_cache_default_sounds()

func _cache_default_sounds() -> void:
	for path in [
		HOVER_PATH,
		CONFIRM_PATH,
		DECLINE_PATH,
		DENIED_PATH,
		PAUSE_PATH,
		UNPAUSE_PATH,
		BATTLE_START_PATH,
		BATTLE_HIT_PATH,
		BATTLE_BLOCK_PATH,
		BATTLE_DEATH_PATH,
		HEAL_PATH,
		BUFF_PATH,
		DEBUFF_PATH,
		DOT_PATH,
	]:
		var stream := load(path) as AudioStream
		if stream == null:
			push_warning("SFX not found: %s" % path)
		else:
			_cache[path] = stream

func bind_button_sounds(root: Node) -> void:
	for button in _find_buttons(root):
		if button.has_meta("sfx_bound"):
			continue
		button.set_meta("sfx_bound", true)
		button.mouse_entered.connect(_on_button_hover.bind(button))
		button.focus_entered.connect(_on_button_hover.bind(button))
		button.pressed.connect(_on_button_pressed.bind(button))

func use_decline_sound(button: Button) -> void:
	button.set_meta(PRESS_SOUND_META, DECLINE_PATH)

func use_denied_sound(button: Button) -> void:
	button.set_meta(PRESS_SOUND_META, DENIED_PATH)

func play_hover() -> void:
	var now := Time.get_ticks_msec()
	if now - _last_hover_msec < HOVER_COOLDOWN_MS:
		return
	_last_hover_msec = now
	play_path(HOVER_PATH)

func play_confirm() -> void:
	play_path(CONFIRM_PATH)

func play_decline() -> void:
	play_path(DECLINE_PATH)

func play_denied() -> void:
	play_path(DENIED_PATH)

func play_pause() -> void:
	play_path(PAUSE_PATH)

func play_unpause() -> void:
	play_path(UNPAUSE_PATH)

func play_battle_start() -> void:
	play_path(BATTLE_START_PATH)

func play_health_result(is_damaging: bool, blocked: bool) -> void:
	if not is_damaging:
		play_path(HEAL_PATH)
	elif blocked:
		play_path(BATTLE_BLOCK_PATH)
	else:
		play_path(BATTLE_HIT_PATH)

func play_status_result(is_buff: bool) -> void:
	play_path(BUFF_PATH if is_buff else DEBUFF_PATH)

func play_dot() -> void:
	play_path(DOT_PATH)

func play_death() -> void:
	play_path(BATTLE_DEATH_PATH)

func play_path(path: String) -> void:
	if path.is_empty():
		return

	var stream := _cache.get(path) as AudioStream
	if stream == null:
		stream = load(path) as AudioStream
		if stream == null:
			push_warning("SFX not found: %s" % path)
			return
		_cache[path] = stream

	var player := _get_available_player()
	player.stream = stream
	player.play()

func _get_available_player() -> AudioStreamPlayer:
	for player in _players:
		if not player.playing:
			return player
	var fallback := _players[0]
	fallback.stop()
	return fallback

func _find_buttons(root: Node) -> Array[Button]:
	var buttons: Array[Button] = []
	_collect_buttons(root, buttons)
	return buttons

func _collect_buttons(node: Node, buttons: Array[Button]) -> void:
	if node is Button:
		buttons.append(node)
	for child in node.get_children():
		_collect_buttons(child, buttons)

func _on_button_hover(button: Button) -> void:
	if not button.disabled:
		play_hover()

func _on_button_pressed(button: Button) -> void:
	if button.disabled:
		play_denied()
	elif button.has_meta(PRESS_SOUND_META):
		play_path(button.get_meta(PRESS_SOUND_META))
	else:
		play_confirm()
