extends Node

signal layer_changed(layer: int)

enum Layer { MASK_OFF = 1, RED = 2, GREEN = 3, BLUE = 4 }

var current_layer: int = Layer.MASK_OFF

func set_layer(layer: int) -> void:
	if layer == current_layer:
		return
	current_layer = layer
	layer_changed.emit(current_layer)
