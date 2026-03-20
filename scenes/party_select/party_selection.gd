extends Control
class_name PartySelector

@onready var party_preview: HBoxContainer = $VBoxContainer/Party
@onready var character_buttons: GridContainer = $VBoxContainer/CharacterButtons

@export var character_slot : PackedScene
@export var stage : PackedScene

func _ready():
	for hero in HeroDatabase.library:
		var h := HeroDatabase.library[hero]
		var c = character_slot.instantiate() as CharacterSelectButton
		
		(c as Button).toggled.connect(
			func(is_on): select_hero(is_on, h))
		character_buttons.add_child(c) 
		
		var elem_icon = c.get_child(0)
		var portrait = c.get_child(1)
		# setting portrait
		portrait.texture = portrait.texture.duplicate()
		portrait.texture.atlas = h.sprite
		
		# Get element component
		var elem_comp : ElementComponent = null
		for val in h.components:
			if val is ElementComponent:
				elem_comp = val
				break
		var e = elem_comp.my_elem if elem_comp else 0
		elem_icon.texture = load("res://assets/jobs/El%skind%s.png" % [str(e+1), str(h.character_class+1)])
		
	character_buttons.get_child(0).call_deferred("grab_focus")

func select_hero(recruited : bool, ch : HeroData) -> void:
	if recruited:
		var p = TextureRect.new()
		p.texture = ch.sprite
		p.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		p.custom_minimum_size = Vector2(128, 283.5)
		party_preview.add_child(p)
		PartyManager.add_member(ch)
	else:
		if ch in PartyManager.party:
			party_preview.get_child(PartyManager.remove_member(ch)).queue_free()
	
	$VBoxContainer/Button.disabled = (PartyManager.party.size() < 1)

func _on_button_pressed() -> void:
	PartyManager.finalize_party()
	get_tree().change_scene_to_packed(stage)
