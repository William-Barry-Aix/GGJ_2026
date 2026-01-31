extends Node

signal layer_changed(layer: int)

@onready var music := get_tree().root.get_node("Music0")

enum Layer { MASK_OFF = 1, RED = 2, GREEN = 3, BLUE = 4 }

var current_layer: int = Layer.MASK_OFF

func set_layer(layer: int) -> void:
	if layer == current_layer:
		return
	current_layer = layer
	layer_changed.emit(current_layer)
	music.change_layer_music(layer)
