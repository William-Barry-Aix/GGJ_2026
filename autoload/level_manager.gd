extends Node

signal layer_changed(layer: int)

enum Layer { MASK_OFF = 1, RED = 2, GREEN = 3, BLUE = 4 }

var current_layer: int = Layer.MASK_OFF

func set_layer(layer: int) -> void:
	if layer == current_layer:
		return
	current_layer = layer
	layer_changed.emit(current_layer)


#extends Node
#
#signal layer_changed(new_layer: int, old_layer: int)
#
#enum Layer { MASK_OFF = 1, RED = 2, GREEN = 3, BLUE = 4}
#
#var current_layer: int = Layer.MASK_OFF
#
##This will emit the layer_changed signal to change the layer
#func set_layer(layer: int) -> void:
	#if layer == current_layer:
		#return
#
	## Validate
	#if layer < Layer.MASK_OFF or layer > Layer.BLUE:
		#push_warning("[LevelManager] Invalid layer: %s" % str(layer))
		#return
#
	#var old := current_layer
	#current_layer = layer
	#layer_changed.emit(current_layer, old)
	##print("[LevelManager] Layer changed %s -> %s" % [old, current_layer])
