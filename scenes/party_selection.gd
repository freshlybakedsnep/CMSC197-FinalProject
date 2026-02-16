extends Control

@onready var party_preview: HBoxContainer = $VBoxContainer/Party
@onready var character_buttons: GridContainer = $VBoxContainer/CharacterButtons
@export var character_slot : PackedScene

var butts : Array

func _ready():
	
	for ch in HeroDatabase.library:
		var c = character_slot.instantiate()
		c.texture = c.texture.duplicate()
		c.texture.atlas = HeroDatabase.library[ch].sprite
		c.pressed.connect(select_hero)
		character_buttons.add_child(c)
		butts.append([c, HeroDatabase.library[ch].entity_name])
	
	character_buttons.get_child(0).call_deferred("grab_focus")

func select_hero(index : int, recruited : bool) -> void:
	var c = butts[index][1]
	if recruited:
		var p = TextureRect.new()
		p.texture = HeroDatabase.library[c].sprite
		p.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		p.custom_minimum_size = Vector2(128, 283.5)
		party_preview.add_child(p)
		PartyManager.add_member(HeroDatabase.library[c])
	else:
		if HeroDatabase.library[c] in PartyManager.party:
			party_preview.get_child(PartyManager.remove_member(HeroDatabase.library[c])).queue_free()
	
	$VBoxContainer/Button.disabled = (PartyManager.party.size() < 1)

func _on_button_pressed() -> void:
	PartyManager.finalize_party()
	get_tree().change_scene_to_file("res://scenes/stage.tscn") 
