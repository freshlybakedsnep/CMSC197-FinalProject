extends Node
class_name PartySelector

signal party_finalized

@onready var party_preview: HBoxContainer = $VBoxContainer/Party
@onready var character_buttons: GridContainer = $VBoxContainer/CharacterButtons

@export var character_slot : PackedScene

const MAX_ROSTER := 8

func _ready():
	BGM.play_party()
	PartyManager.party.clear()
	var heroes: Array[HeroData] = []
	for key in HeroDatabase.library.keys():
		var hero := HeroDatabase.library[key]
		if hero != null and PartyManager.is_unlocked(hero.entity_name):
			heroes.append(hero)
	heroes.sort_custom(func(a: HeroData, b: HeroData) -> bool:
		return a.entity_name < b.entity_name)
	if heroes.size() > MAX_ROSTER:
		heroes = heroes.slice(0, MAX_ROSTER)
	for h in heroes:
		var c = character_slot.instantiate() as CharacterSelectButton
		(c as Button).toggled.connect(func(is_on): select_hero(is_on, h))
		character_buttons.add_child(c)
		var elem_icon = c.get_child(0)
		var portrait = c.get_child(1)
		portrait.texture = h.sprite
		var elem_comp: ElementComponent = null
		for val in h.components:
			if val is ElementComponent:
				elem_comp = val
				break
		var e = elem_comp.my_elem if elem_comp else 0
		elem_icon.texture = load("res://assets/jobs/El%skind%s.png" % [str(e + 1), str(h.character_class + 1)])
		(c as Button).tooltip_text = "%s | %s | %s" % [h.entity_name, _class_to_text(h.character_class), _gender_to_text(h.gender)]
	if character_buttons.get_child_count() > 0:
		character_buttons.get_child(0).call_deferred("grab_focus")

func select_hero(recruited : bool, ch : HeroData) -> void:
	if recruited:
		if PartyManager.add_member(ch):
			var p = TextureRect.new()
			p.texture = ch.sprite
			p.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			p.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
			p.clip_contents = true
			var target_height := party_preview.custom_minimum_size.y
			if target_height <= 0.0:
				target_height = 283.5
			p.custom_minimum_size = Vector2(128, target_height)
			party_preview.add_child(p)
	else:
		if ch in PartyManager.party:
			party_preview.get_child(PartyManager.remove_member(ch)).queue_free()
	
	$VBoxContainer/StartBattle.disabled = (PartyManager.party.size() < 1)

func start_battle() -> void:
	PartyManager.finalize_party()
	party_finalized.emit()
	queue_free()

func reselect_stage() -> void:
	BGM.play_world()
	queue_free()

func _class_to_text(character_class: HeroData.CharacterClass) -> String:
	match character_class:
		HeroData.CharacterClass.DUELIST:
			return "Duelist"
		HeroData.CharacterClass.JUGGERNAUT:
			return "Juggernaut"
		HeroData.CharacterClass.HEALER:
			return "Healer"
		HeroData.CharacterClass.TACTICIAN:
			return "Tactician"
		HeroData.CharacterClass.VANDAL:
			return "Vandal"
		_:
			return "Unknown"

func _gender_to_text(gender: HeroData.Gender) -> String:
	match gender:
		HeroData.Gender.MALE:
			return "Male"
		HeroData.Gender.FEMALE:
			return "Female"
		_:
			return "Unknown"
