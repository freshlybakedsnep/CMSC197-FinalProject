extends Control
class_name PartySelector

@onready var party_preview: HBoxContainer = $VBoxContainer/Party
@onready var character_buttons: GridContainer = $VBoxContainer/CharacterButtons

@export var character_slot : PackedScene
@export var stage : PackedScene

const MAX_ROSTER := 8

func _ready():
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
		portrait.texture = portrait.texture.duplicate()
		portrait.texture.atlas = h.sprite
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
			p.custom_minimum_size = Vector2(128, 283.5)
			party_preview.add_child(p)
	else:
		if ch in PartyManager.party:
			party_preview.get_child(PartyManager.remove_member(ch)).queue_free()
	
	$VBoxContainer/Button.disabled = (PartyManager.party.size() < 1)

func _on_button_pressed() -> void:
	PartyManager.finalize_party()
	get_tree().change_scene_to_packed(stage)

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
