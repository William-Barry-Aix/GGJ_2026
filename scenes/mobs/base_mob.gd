extends CharacterBody2D
class_name BaseMob

signal mob_died(mob: BaseMob)

@export var move_speed: float = 120.0
@export var default_anim: StringName = &"default"

@onready var anim: AnimationPlayer = get_node_or_null("AnimationPlayer") as AnimationPlayer
@onready var health: Health = $Health
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var hitbox: Hitbox = $Hitbox
@onready var agent: NavigationAgent2D = $NavigationAgent2D if has_node("NavigationAgent2D") else null

var target: Node2D = null
var is_alive: bool = true

func _ready() -> void:
	add_to_group("mob")
	GameConfig.setup_mob_body(self)

	if health:
		health.died.connect(_on_died)
		print("[BaseMob] ", name, " connected to health.died. HP=", health.current_health)
	if hitbox:
		hitbox.target_group = &"player"
		hitbox.set_active(false)

	_play_default_anim()


func _play_default_anim() -> void:
	if anim == null:
		return
	if default_anim == &"":
		return
	if not anim.has_animation(default_anim):
		push_warning("[BaseMob] AnimationPlayer missing animation '%s' on %s" % [String(default_anim), name])
		return

	# Ensure it loops (the animation resource itself should also be set to loop in the editor)
	anim.play(default_anim)

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
	print("[BaseMob] _on_died called for ", name)
	is_alive = false
	set_physics_process(false)
	set_process(false)

	if anim:
		anim.stop()

	mob_died.emit(self)

	queue_free()
