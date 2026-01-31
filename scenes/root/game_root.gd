extends Node
class_name GameRoot

@export var debug_print: bool = false

@onready var world: Node = $World
@onready var player: Player = $World/Player

var current_level: BaseLevel

func _ready() -> void:
	LevelManager.set_layer(LevelManager.Layer.MASK_OFF)

	if world == null:
		push_error("[GameRoot] Missing node: World")
		return

	current_level = get_tree().get_first_node_in_group("level") as BaseLevel
	if current_level == null:
		current_level = _find_level_under_world(world)
	if current_level == null:
		push_error("[GameRoot] No BaseLevel found under World. Add a level scene that extends BaseLevel.")
		return

	if player == null:
		push_error("[GameRoot] Missing node: World/Player")
		return

	# Apply layer once on boot so visuals match immediately
	current_level.on_layer_changed(LevelManager.current_layer)

	if debug_print:
		print("[GameRoot] Ready. Level=", current_level.name, " Player=", player.name)


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
