extends Node
class_name GameRoot

#Define variables for the World, CurrentLevel and Player (both under Node)

func _ready() -> void:
	pass


#TODO: Define how we'll load/unload the levels
func load_level() -> void:
	pass
	

#Used when loading the scene for the first time, or when the player dies
func _spawn_player() -> void:
	pass
