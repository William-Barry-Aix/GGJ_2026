extends CharacterBody2D
class_name Player

signal died()

@export var move_speed: float = 300.0
@export var attack_duration: float = 0.12
@export var attack_cooldown: float = 0.20

@onready var health: Health = $Health
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var melee_hitbox: Hitbox = $Hitbox

var _can_attack: bool = true

func _ready() -> void:
	add_to_group("player")
	health.died.connect(_on_died)

	# Make sure hitbox starts off
	melee_hitbox.set_active(false)

func _physics_process(delta: float) -> void:
	_handle_layer_hotkeys()
	_handle_movement(delta)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		try_attack()

func _handle_layer_hotkeys() -> void:
	if Input.is_action_just_pressed("layer_1"):
		LevelManager.set_layer(LevelManager.Layer.MASK_OFF)
	elif Input.is_action_just_pressed("layer_2"):
		LevelManager.set_layer(LevelManager.Layer.RED)
	elif Input.is_action_just_pressed("layer_3"):
		LevelManager.set_layer(LevelManager.Layer.GREEN)
	elif Input.is_action_just_pressed("layer_4"):
		LevelManager.set_layer(LevelManager.Layer.BLUE)

func _handle_movement(_delta: float) -> void:
	var input := Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized()

	velocity = input * move_speed
	move_and_slide()


### Combat and death ###

func try_attack() -> void:
	# Optional: disable attacks when mask off
	if LevelManager.current_layer == LevelManager.Layer.MASK_OFF:
		return
	if not _can_attack:
		return

	_can_attack = false
	melee_hitbox.set_active(true)

	# In a jam this is fine; later you can use AnimationPlayer not awaits.
	await get_tree().create_timer(attack_duration).timeout
	melee_hitbox.set_active(false)

	await get_tree().create_timer(attack_cooldown).timeout
	_can_attack = true

func reset_after_respawn() -> void:
	health.reset_full()

func _on_died() -> void:
	died.emit()
