extends CharacterBody2D
class_name Player

signal died()
signal reset_mob_target_pos(Vector2)

@export var move_speed: float = 300.0
@export var attack_duration: float = 0.12
@export var attack_cooldown: float = 0.20
@export var debug_input := false

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var health: Health = $Health
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var melee_hitbox: Hitbox = $Hitbox

# Optional audio nodes (keep your names)
@onready var io_walk: AudioStreamPlayer2D = $io_walk
@onready var io_sword_sfx := $io_sword_sfx

enum Facing { RIGHT, LEFT }
var facing: int = Facing.RIGHT

var _can_attack: bool = true
var _attacking: bool = false
var is_alive: bool = true


func _ready() -> void:
	add_to_group("player")
	GameConfig.setup_player_body(self)

	if health:
		health.died.connect(_on_died)

	if melee_hitbox:
		melee_hitbox.set_active(false)

	# Start idle facing right by default
	_play_anim("idle_right")


func _physics_process(_delta: float) -> void:
	if not is_alive:
		return

	_handle_layer_hotkeys()
	_handle_movement()
	if Input.is_action_just_pressed("attack"):
		try_attack()

func _input(event: InputEvent) -> void:
	if not debug_input:
		return
	if event is InputEventMouseButton and event.pressed:
		var mb := event as InputEventMouseButton
		print("[Input] mouse button=", mb.button_index, " attack_action=", event.is_action_pressed("attack"))

func _handle_layer_hotkeys() -> void:
	if Input.is_action_just_pressed("layer_1"):
		LevelManager.set_layer(LevelManager.Layer.MASK_OFF)
	elif Input.is_action_just_pressed("layer_2"):
		LevelManager.set_layer(LevelManager.Layer.RED)
	elif Input.is_action_just_pressed("layer_3"):
		LevelManager.set_layer(LevelManager.Layer.GREEN)
	elif Input.is_action_just_pressed("layer_4"):
		LevelManager.set_layer(LevelManager.Layer.BLUE)


func _handle_movement() -> void:
	var raw := Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)

	var input := raw.normalized()
	velocity = input * move_speed
	move_and_slide()

	# Walking sound: only while actually moving (and not spamming restart)
	var moving := raw.length() > 0.01
	if io_walk:
		if moving and not io_walk.playing:
			io_walk.play()
		elif not moving and io_walk.playing:
			io_walk.stop()

	# Don't override attack animation while attacking
	if _attacking:
		return

	# Facing logic:
	# - If moving mostly horizontally (or diagonal with x dominant) -> update facing
	# - If moving purely vertical -> keep current facing
	if moving:
		if abs(raw.x) >= abs(raw.y) and abs(raw.x) > 0.01:
			facing = Facing.RIGHT if raw.x > 0.0 else Facing.LEFT

		_play_anim("walk_right" if facing == Facing.RIGHT else "walk_left")
	else:
		_play_anim("idle_right" if facing == Facing.RIGHT else "idle_left")


### Combat and death ###

func try_attack() -> void:
	if not is_alive:
		return
	if not _can_attack:
		return
	if melee_hitbox == null:
		return

	_can_attack = false
	_attacking = true

	# Always play the animation
	_play_anim("attack_right" if facing == Facing.RIGHT else "attack_left")

	# Only do damage when NOT mask off
	var can_damage := LevelManager.current_layer != LevelManager.Layer.MASK_OFF

	# Activate hitbox only if damaging
	melee_hitbox.set_active(can_damage)

	# Sound can play regardless (your choice)
	if io_sword_sfx and io_sword_sfx.has_method("PLAYBACK_RANDOM"):
		io_sword_sfx.PLAYBACK_RANDOM()

	await get_tree().create_timer(attack_duration).timeout
	if not is_alive or not is_inside_tree():
		return

	melee_hitbox.set_active(false)
	_attacking = false

	# Back to locomotion anim
	if velocity.length() > 0.01:
		_play_anim("walk_right" if facing == Facing.RIGHT else "walk_left")
	else:
		_play_anim("idle_right" if facing == Facing.RIGHT else "idle_left")

	await get_tree().create_timer(attack_cooldown).timeout
	if not is_alive or not is_inside_tree():
		return
	_can_attack = true



func reset_after_respawn() -> void:
	is_alive = true
	_attacking = false
	health.reset_full()
	_can_attack = true

	if melee_hitbox:
		melee_hitbox.set_active(false)

	_play_anim("idle_right" if facing == Facing.RIGHT else "idle_left")


func _on_died() -> void:
	is_alive = false
	_attacking = false
	_can_attack = false

	if melee_hitbox:
		melee_hitbox.set_active(false)

	velocity = Vector2.ZERO

	# Optional: stop walking sound on death
	if io_walk and io_walk.playing:
		io_walk.stop()

	died.emit() # REQUIRED so GameRoot respawns


### Animation helper ###

func _play_anim(name: String) -> void:
	if anim == null:
		return
	if anim.current_animation == name and anim.is_playing():
		return
	if anim.has_animation(name):
		anim.play(name)
	else:
		push_warning("[Player] Missing animation: %s" % name)
