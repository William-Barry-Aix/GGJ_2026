extends Node2D
class_name GhostSwarmManager

@export var ghost_scene: PackedScene
@export var spawn_radius: float = 280.0
@export var min_radius: float = 80.0

var _ghosts: Array[Node] = []
var _kill_tracker: KillTracker
var _rng := RandomNumberGenerator.new()
var _desired_count: int = 0

func _ready() -> void:
	_rng.randomize()

	_kill_tracker = get_tree().get_first_node_in_group("kill_tracker") as KillTracker
	if _kill_tracker:
		_desired_count = _kill_tracker.bolzeur_kills
		_kill_tracker.bolzeur_kills_changed.connect(_on_bolzeur_kills_changed)

	LevelManager.layer_changed.connect(_on_layer_changed)

	# Apply initial
	_on_layer_changed(LevelManager.current_layer)

func _exit_tree() -> void:
	if LevelManager.layer_changed.is_connected(_on_layer_changed):
		LevelManager.layer_changed.disconnect(_on_layer_changed)
	if _kill_tracker and _kill_tracker.bolzeur_kills_changed.is_connected(_on_bolzeur_kills_changed):
		_kill_tracker.bolzeur_kills_changed.disconnect(_on_bolzeur_kills_changed)

func _on_bolzeur_kills_changed(count: int) -> void:
	_desired_count = count

	# If we’re currently in MASK_OFF, respawn immediately (random reset behavior)
	if LevelManager.current_layer == LevelManager.Layer.MASK_OFF:
		_respawn_all()

func _on_layer_changed(layer: int) -> void:
	if layer == LevelManager.Layer.MASK_OFF:
		_respawn_all()
	else:
		_despawn_all()

func _respawn_all() -> void:
	_despawn_all()

	if _desired_count <= 0:
		return
	if ghost_scene == null:
		push_warning("[GhostSwarmManager] ghost_scene not set.")
		return

	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		push_warning("[GhostSwarmManager] No player found.")
		return

	for i in range(_desired_count):
		var g := ghost_scene.instantiate() as Node2D
		g.global_position = player.global_position + _random_offset()
		add_child(g)
		_ghosts.append(g)

func _despawn_all() -> void:
	for g in _ghosts:
		if is_instance_valid(g):
			g.queue_free()
	_ghosts.clear()

func _random_offset() -> Vector2:
	var angle := _rng.randf_range(0.0, TAU)
	var r := _rng.randf_range(min_radius, spawn_radius)
	return Vector2(cos(angle), sin(angle)) * r
