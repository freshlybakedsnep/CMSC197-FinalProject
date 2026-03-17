@tool
extends EntityComponent
class_name ElementComponent

func _init() -> void:
	type = Type.ELEMENT

enum Element {FIRE, WATER, WOOD, LIGHT, DARK, NONE}

# attacker : {defender : multiplier}
const TYPE_CHART = {
	Element.FIRE	: {Element.WATER: 0.5, Element.WOOD: 2.0},
	Element.WATER	: {Element.WOOD: 0.5, Element.FIRE: 2.0},
	Element.WOOD	: {Element.FIRE: 0.5, Element.WATER: 2.0},
	Element.LIGHT	: {Element.DARK: 2.0},
	Element.DARK	: {Element.LIGHT: 2.0},
}

@export var my_elem : Element = Element.NONE

func get_damage_mult(attacker_element: Element) -> float:
	if not TYPE_CHART.has(attacker_element):
		return 1.0
	
	return TYPE_CHART.get(attacker_element).get(my_elem, 1.0)
