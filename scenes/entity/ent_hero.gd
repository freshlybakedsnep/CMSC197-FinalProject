extends EntityData
class_name HeroData

const MAX_SKILLS_SLOT = 2

@export var character_class : CharacterClass
enum CharacterClass {
	DUELIST,
	JUGGERNAUT,
	HEALER,
	TACTICIAN,
	VANDAL
}

@export var idle_voice_lines: Array[AudioStream] = []
@export var idle_line_texts: PackedStringArray = []
@export var idle_bark_interval := 8.0

@export var battle_voice_lines: Array[AudioStream] = []
@export var battle_line_texts: PackedStringArray = []
@export var battle_bark_interval := 10.0

@export var win_voice_lines: Array[AudioStream] = []
@export var win_line_texts: PackedStringArray = []

@export var lose_voice_lines: Array[AudioStream] = []
@export var lose_line_texts: PackedStringArray = []
