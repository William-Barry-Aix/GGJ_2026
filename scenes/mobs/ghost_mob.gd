extends BaseMob
class_name GhostMob

@export var attack_damage: int = 10
@export var attack_active: bool = true   # keep on, or you can add cooldown logic later

@export var repath_interval: float = 0.15  # how often to refresh agent target
var _repath_timer: float = 0.0

func _ready() -> void:
	super._ready()

	# Find and track the player
	var p := get_tree().get_first_node_in_group("player") as Node2D
	if p:
		set_target(p)
	else:
		push_warning("[GhostMob] No player found in group 'player'.")

	# Ghost hitbox should hit the player
	if hitbox:
		hitbox.damage = attack_damage
		hitbox.target_group = &"player"
		hitbox.set_active(attack_active)

	# Optional: make sure agent is configured sensibly
	if agent:
		agent.path_desired_distance = 6.0
		agent.target_desired_distance = 8.0
		agent.avoidance_enabled = true

func _physics_process(delta: float) -> void:
	if not is_alive:
		return

	# If player got respawned or swapped, re-acquire (safety)
	if target == null or not is_instance_valid(target):
		var p := get_tree().get_first_node_in_group("player") as Node2D
		if p:
			set_target(p)

	# Keep navigation agent updated a few times per second
	_repath_timer += delta
	if agent and target and _repath_timer >= repath_interval:
		_repath_timer = 0.0
		agent.target_position = target.global_position

	# Use BaseMob movement helper (it uses agent if present)
	_move_towards_target()
