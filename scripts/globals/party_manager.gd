extends Node
class_name Party

var party : Array[HeroData] = []
const MAX_PARTY_SIZE = 5

var unlocked_heroes: Dictionary = {}
var intro_seen : bool = false
const SAVE_PATH := "user://progress.cfg"

func _ready() -> void:
	load_progress()

func unlock_hero(hero_name: String) -> void:
	unlocked_heroes[hero_name] = true
	save_progress()

func load_progress() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	intro_seen = cfg.get_value("progress", "intro_seen", false)
	unlocked_heroes = cfg.get_value("progress", "unlocked_heroes", {})

func save_progress() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("progress", "intro_seen", intro_seen)
	cfg.set_value("progress", "unlocked_heroes", unlocked_heroes)
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
