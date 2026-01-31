extends CharacterBody2D
class_name BaseMob

@export var move_speed: float = 120.0
@export var repath_interval: float = 0.2  # how often we refresh target position

@onready var health: Health = $Health
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var agent: NavigationAgent2D = $NavigationAgent2D if has_node("NavigationAgent2D") else null

var target: Node2D = null
var is_alive: bool = true

var _repath_t: float = 0.0

func _ready() -> void:
	add_to_group("mob")
	GameConfig.setup_mob_body(self)
	health.died.connect(_on_died)

	# Nav defaults (safe even if you tweak in inspector)
	if agent:
		agent.path_desired_distance = 4.0
		agent.target_desired_distance = 6.0
		agent.avoidance_enabled = false # turn on later if you want separation

func set_target(t: Node2D) -> void:
	target = t
	_repath_t = repath_interval # force immediate repath

func _physics_process(delta: float) -> void:
	# Base class does nothing; children decide when to chase
	pass

func _move_towards_target(delta: float) -> void:
	if target == null:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# If we have a nav agent AND the nav map exists, use it
	if agent and agent.is_navigation_finished() == false:
		# refresh target position periodically (player moves)
		_repath_t -= delta
		if _repath_t <= 0.0:
			_repath_t = repath_interval
			agent.target_position = target.global_position

		var next_pos := agent.get_next_path_position()
		var dir := (next_pos - global_position)
		if dir.length_squared() > 0.0001:
			dir = dir.normalized()
			velocity = dir * move_speed
		else:
			velocity = Vector2.ZERO

		move_and_slide()
		return

	# If agent exists but thinks navigation is finished, set a new target and try again
	if agent:
		agent.target_position = target.global_position
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# Fallback: dumb chase (only if no agent node exists)
	var dir2 := (target.global_position - global_position).normalized()
	velocity = dir2 * move_speed
	move_and_slide()

func _on_died() -> void:
	is_alive = false
	set_physics_process(false)
	set_process(false)
	queue_free()
