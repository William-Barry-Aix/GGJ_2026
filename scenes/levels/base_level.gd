extends Node2D
class_name BaseLevel

func _ready() -> void:
	#Listen to the LevelManager signal to call the handler when the layer is changed
	LevelManager.layer_changed.connect(on_layer_changed)
	pass

#Handles Environment and Mob changes on layer switch
func on_layer_changed(layer: int) -> void:
	pass
