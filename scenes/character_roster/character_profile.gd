extends Resource
class_name CharacterProfile

enum Role {
	DUELIST,
	JUGGERNAUT,
	HEALER,
	TACTICIAN,
	VANDAL
}

enum Gender {
	MALE,
	FEMALE
}

@export var character_name := "Unnamed"
@export var role : Role = Role.DUELIST
@export var gender : Gender = Gender.MALE
@export var sprite : Texture2D
@export_multiline var notes := ""
