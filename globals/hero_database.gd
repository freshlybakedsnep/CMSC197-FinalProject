extends Node
@export var library : Dictionary = {}

# path to heroe .tres files
const DATA_PATH = "res://resources/heroes/"

func _ready() -> void:
	load_all()

func load_all() -> void:
	var dir = DirAccess.open(DATA_PATH)
	if not dir:
		push_error("Directory not found at " + DATA_PATH)
		return
		
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name.ends_with(".tres") or file_name.ends_with(".res") or file_name.ends_with(".remap"): 
			var clean_path = DATA_PATH + file_name.replace(".remap", "")
			var res = ResourceLoader.load(clean_path)
			
			if res is HeroData:
				library[res.entity_name] = res
		
		file_name = dir.get_next()
	print("Library: Loaded ", library.size(), " characters.")
