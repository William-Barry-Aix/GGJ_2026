extends Node2D
class_name BaseLevel

@export var debug_print_layer: bool = false
@onready var layer_tint: CanvasModulate = get_node_or_null("LayerTint") as CanvasModulate

func _enter_tree() -> void:
	add_to_group("level")
	LevelManager.layer_changed.connect(on_layer_changed)

func _ready() -> void:
	if not LevelManager.layer_changed.is_connected(on_layer_changed):
		LevelManager.layer_changed.connect(on_layer_changed)

	# Apply initial state
	on_layer_changed(LevelManager.current_layer)

func _exit_tree() -> void:
	if LevelManager.layer_changed.is_connected(on_layer_changed):
		LevelManager.layer_changed.disconnect(on_layer_changed)

func on_layer_changed(layer: int) -> void:
	if debug_print_layer:
		print("[BaseLevel] on_layer_changed -> ", layer)

	if layer_tint == null:
		push_warning("[BaseLevel] Missing CanvasModulate named 'LayerTint' in this level.")
		return

	layer_tint.color = _color_for_layer(layer)

func _color_for_layer(layer: int) -> Color:
	match layer:
		LevelManager.Layer.MASK_OFF:
			return Color(1, 1, 1, 1)
		LevelManager.Layer.RED:
			return Color(1.0, 0.55, 0.55, 1)
		LevelManager.Layer.GREEN:
			return Color(0.55, 1.0, 0.55, 1)
		LevelManager.Layer.BLUE:
			return Color(0.55, 0.70, 1.0, 1)
		_:
			return Color(1, 1, 1, 1)
