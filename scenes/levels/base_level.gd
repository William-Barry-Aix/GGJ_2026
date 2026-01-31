extends Node2D
class_name BaseLevel

@export var debug_print_layer: bool = false
@onready var layer_tint: CanvasModulate = get_node_or_null("LayerTint") as CanvasModulate

func _enter_tree() -> void:
	add_to_group("level")
	LevelManager.layer_changed.connect(on_layer_changed)
	
@onready var walls_green: TileMapLayer = get_node_or_null("WallsGreen") as TileMapLayer
@onready var spikes_red: TileMapLayer = get_node_or_null("SpikesRed") as TileMapLayer
@onready var holes_blue: TileMapLayer = get_node_or_null("HolesBlue") as TileMapLayer

var _base_collision_layer: int = 0
var _walls_green_base_collision_layer: int = 1
var _spikes_red_base_collision_layer: int = 2
var _holes_blue_base_collision_layer: int = 3
var _active_collision_layer: int = 0
func _ready() -> void:
	if not LevelManager.layer_changed.is_connected(on_layer_changed):
		LevelManager.layer_changed.connect(on_layer_changed)

	# Apply initial state
	on_layer_changed(LevelManager.current_layer)

func _exit_tree() -> void:
	if LevelManager.layer_changed.is_connected(on_layer_changed):
		LevelManager.layer_changed.disconnect(on_layer_changed)

func get_player_spawn() -> Marker2D:
	var m := get_node_or_null("Markers/PlayerSpawn") as Marker2D
	return m


func on_layer_changed(layer: int) -> void:
	if debug_print_layer:
		print("[BaseLevel] on_layer_changed -> ", layer)

	if layer_tint == null:
		push_warning("[BaseLevel] Missing CanvasModulate named 'LayerTint' in this level.")
	else:
		layer_tint.color = _color_for_layer(layer)

	_update_tilemaps_for_layer(layer)

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

func _update_tilemaps_for_layer(layer: int) -> void:
	_set_tilemap_active(walls_green, layer == LevelManager.Layer.GREEN, _walls_green_base_collision_layer)
	_set_tilemap_active(spikes_red, layer == LevelManager.Layer.RED, _spikes_red_base_collision_layer)
	_set_tilemap_active(holes_blue, layer == LevelManager.Layer.BLUE, _holes_blue_base_collision_layer)

func _set_tilemap_active(tilemap: TileMapLayer, is_active: bool, base_collision_layer: int) -> void:
	if tilemap == null:
		return

	if is_active:
		tilemap.visible = true
		_active_collision_layer = base_collision_layer

	else:
		tilemap.visible = false
