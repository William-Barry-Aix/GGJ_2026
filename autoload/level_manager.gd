extends Node

signal layer_changed(layer: int)

enum Layer { MASK_OFF = 1, RED = 2, GREEN = 3, BLUE = 4}

var current_layer: int = Layer.MASK_OFF

#This will emit the layer_changed signal to change the layer
func set_layer(layer: int) -> void:
	pass
