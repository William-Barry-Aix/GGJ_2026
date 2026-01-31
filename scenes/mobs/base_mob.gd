extends CharacterBody2D
class_name BaseMob

@export var move_speed: float = 120.0

@onready var health: Health = $Health
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var agent: NavigationAgent2D = $NavigationAgent2D if has_node("NavigationAgent2D") else null

var target: Node2D = null
var is_alive: bool = true

func _ready() -> void:
	add_to_group("mob")
	health.died.connect(_on_died)

func set_target(t: Node2D) -> void:
	target = t

func _physics_process(delta: float) -> void:
	# Base class does nothing by default.
	# Children can call _move_towards_target() if they want.
	pass

func _move_towards_target() -> void:
	if target == null:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if agent:
		agent.target_position = target.global_position
		var next_pos := agent.get_next_path_position()
		var dir := (next_pos - global_position).normalized()
		velocity = dir * move_speed
	else:
		var dir2 := (target.global_position - global_position).normalized()
		velocity = dir2 * move_speed

	move_and_slide()


func _on_died() -> void:
	# Immediately stop behavior this frame
	is_alive = false
	set_physics_process(false)
	set_process(false)

	# If you have hitboxes/attacks, child classes can override to disable them too
	queue_free()
