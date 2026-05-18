extends Node
class_name Party

var party : Array[HeroData] = []
const MAX_PARTY_SIZE = 5

var unlocked_heroes: Dictionary = {}
var cleared_battles: Dictionary = {}
var intro_seen : bool = false
const SAVE_PATH := "res://user/progress/progress.cfg"

var _active_battle_id: String = ""
var _active_battle_label: String = ""
var _active_unlock_heroes: PackedStringArray = []

func _ready() -> void:
	load_progress()

func is_unlocked(hero_name: String) -> bool:
	return unlocked_heroes.get(hero_name, false)

func unlock_hero(hero_name: String) -> void:
	unlocked_heroes[hero_name] = true
	save_progress()

func set_active_battle(battle_id: String, battle_label: String = "", unlock_heroes: PackedStringArray = PackedStringArray()) -> void:
	_active_battle_id = battle_id.strip_edges()
	_active_battle_label = battle_label
	_active_unlock_heroes = unlock_heroes

func clear_active_battle() -> void:
	_active_battle_id = ""
	_active_battle_label = ""
	_active_unlock_heroes = PackedStringArray()

func apply_active_battle_win_unlocks() -> Dictionary:
	var result := {
		"battle_id": _active_battle_id,
		"battle_label": _active_battle_label,
		"is_new_clear": false,
		"newly_unlocked": PackedStringArray()
	}
	if _active_battle_id.is_empty():
		return result
	
	if cleared_battles.get(_active_battle_id, false):
		clear_active_battle()
		return result
	
	cleared_battles[_active_battle_id] = true
	result["is_new_clear"] = true
	
	var newly_unlocked := PackedStringArray()
	for hero_name in _active_unlock_heroes:
		var clean_name := String(hero_name).strip_edges()
		if clean_name.is_empty():
			continue
		if not is_unlocked(clean_name):
			unlocked_heroes[clean_name] = true
			newly_unlocked.append(clean_name)
	
	result["newly_unlocked"] = newly_unlocked
	save_progress()
	clear_active_battle()
	return result

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func reset_progress() -> void:
	intro_seen = false
	unlocked_heroes.clear()
	cleared_battles.clear()
	party.clear()
	clear_active_battle()
	var abs_path := ProjectSettings.globalize_path(SAVE_PATH)
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(abs_path)

func load_progress() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	intro_seen = cfg.get_value("progress", "intro_seen", false)
	unlocked_heroes = cfg.get_value("progress", "unlocked_heroes", {})
	cleared_battles = cfg.get_value("progress", "cleared_battles", {})

func save_progress() -> void:
	var abs_dir := ProjectSettings.globalize_path("res://user/progress")
	DirAccess.make_dir_recursive_absolute(abs_dir)
	
	var cfg := ConfigFile.new()
	cfg.set_value("progress", "intro_seen", intro_seen)
	cfg.set_value("progress", "unlocked_heroes", unlocked_heroes)
	cfg.set_value("progress", "cleared_battles", cleared_battles)
	cfg.save(SAVE_PATH)

func add_member(hero : HeroData) -> bool:
	if hero in party or party.size() >= MAX_PARTY_SIZE:
		return false
	
	party.append(hero)
	return true

func remove_member(hero : HeroData) -> int:
	var index = party.find(hero)
	party.erase(hero)
	return index

func finalize_party() -> void:
	for slot in party.size():
		party[slot] = party[slot].duplicate(true)
		party[slot].initialize()
