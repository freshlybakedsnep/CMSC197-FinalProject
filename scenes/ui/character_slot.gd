extends TextureRect
signal pressed(index : int, toggled : bool)

func _on_toggle(toggled : bool) -> void:
	if toggled:
		if PartyManager.party.size() >= 5:
			$Button.button_pressed = false
			return
		pressed.emit(get_index(), true)
	else:
		pressed.emit(get_index(), toggled)

func _on_focus_entered() -> void:
	$Button.grab_focus()
