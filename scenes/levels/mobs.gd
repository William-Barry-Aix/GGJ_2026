extends Node2D

const BOLZEUR_NODE := preload("res://scenes/mobs/bolzeur.tscn")
const GHOST_NODE   := preload("res://scenes/mobs/ghost_mob.tscn") # <-- adjust path if yours differs

@export var bolzeur_count: int = 0
@export var ghost_count: int = 1
@export var spawn_radius: float = 640.0
@export var min_spawn_distance: float = 120.0 # don't spawn on top of player

@onready var projectiles_manager := %ProjectilesManager

func _ready() -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		push_error("[Mobs] No node in group 'player' found. Can't spawn mobs around player.")
		return

	_spawn_many_around_player(player, BOLZEUR_NODE, bolzeur_count, true)
	_spawn_many_around_player(player, GHOST_NODE, ghost_count, false)

func _spawn_many_around_player(player: Node2D, scene: PackedScene, count: int, connect_bolzeur: bool) -> void:
	for i in range(count):
		var p := _random_point_in_ring(player.global_position, min_spawn_distance, spawn_radius)
		var mob := scene.instantiate()
		mob.global_position = p
		add_child(mob)

		# Optional hookup only for bolzeur-like mobs
		if connect_bolzeur and mob.has_signal("request_radial_shot"):
			mob.request_radial_shot.connect(projectiles_manager.on_bolzeur_radial)

func _random_point_in_ring(center: Vector2, min_r: float, max_r: float) -> Vector2:
	# Uniform-ish distribution in area (important: use sqrt on radius)
	var angle := randf() * TAU
	var r := sqrt(randf() * (max_r * max_r - min_r * min_r) + min_r * min_r)
	return center + Vector2(cos(angle), sin(angle)) * r
