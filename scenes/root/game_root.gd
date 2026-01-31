extends Node
class_name GameRoot

@export var debug_print: bool = false
@export var respawn_delay: float = 0.6

@onready var world: Node = $World
@onready var player: Player = $World/Player
@onready var hud: HUD = $UI/HUD


var current_level: BaseLevel

func _ready() -> void:
	LevelManager.set_layer(LevelManager.Layer.MASK_OFF)

	current_level = get_tree().get_first_node_in_group("level") as BaseLevel
	if current_level == null:
		current_level = _find_level_under_world(world)
	if current_level == null:
		push_error("[GameRoot] No BaseLevel found under World.")
		return

	if player == null:
		push_error("[GameRoot] Missing node: World/Player")
		return

	# Bind HUD to player health
	if hud:
		hud.bind_player(player)

	# Respawn on death
	if not player.died.is_connected(_on_player_died):
		player.died.connect(_on_player_died)

	# Place player at spawn on start
	_respawn_player()

func _find_level_under_world(world_node: Node) -> BaseLevel:
	# Prefer direct children (your current structure: World -> Level)
	for c in world_node.get_children():
		if c is BaseLevel:
			return c as BaseLevel

	# Fallback: search deeper (in case someone nests it)
	for c in world_node.get_children():
		var found := _find_level_recursive(c)
		if found != null:
			return found

	return null


func _find_level_recursive(n: Node) -> BaseLevel:
	if n is BaseLevel:
		return n as BaseLevel
	for c in n.get_children():
		var found := _find_level_recursive(c)
		if found != null:
			return found
	return null


func _on_player_died() -> void:
	if debug_print:
		print("[GameRoot] Player died -> respawning")
	await get_tree().create_timer(respawn_delay).timeout
	_respawn_player()

func _respawn_player() -> void:
	if current_level == null:
		return

	var spawn := current_level.get_player_spawn()
	if spawn:
		player.global_position = spawn.global_position
	else:
		push_warning("[GameRoot] No spawn marker found in level Markers/PlayersSpawn")

	player.reset_after_respawn()
