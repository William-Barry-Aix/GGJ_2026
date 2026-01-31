extends Node
class_name GameRoot

#Define variables for the World, CurrentLevel and Player (both under Node)
@export var player_scene: PackedScene
@export var initial_level_scene: PackedScene

var world: Node
var current_level: BaseLevel
var player: Player

func _ready() -> void:
	world = Node.new()
	world.name = "World"
	add_child(world)
	LevelManager.set_layer(LevelManager.Layer.MASK_OFF)
	load_level(initial_level_scene)


#TODO: Define how we'll load/unload the levels
func load_level(level_scene: PackedScene) -> void:
	# Unload old
	if is_instance_valid(current_level):
		current_level.queue_free()
		current_level = null

	# Load new
	if level_scene == null:
		push_error("[GameRoot] No level scene provided.")
		return

	current_level = level_scene.instantiate() as BaseLevel
	world.add_child(current_level)

	_spawn_player()

	# Apply current layer immediately (so visuals match when loading)
	current_level.on_layer_changed(LevelManager.current_layer)

	

#Used when loading the scene for the first time, or when the player dies
func _spawn_player() -> void:
	if player_scene == null:
		push_error("[GameRoot] No player_scene provided.")
		return

	if is_instance_valid(player):
		player.queue_free()

	player = player_scene.instantiate() as Player
	world.add_child(player)

	# Optional: spawn point support
	var spawn := current_level.get_node_or_null("PlayerSpawn") as Node2D
	if spawn:
		player.global_position = spawn.global_position
	else:
		player.global_position = Vector2.ZERO
