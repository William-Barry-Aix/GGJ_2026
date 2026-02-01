extends CharacterBody2D
class_name Player

signal died()
signal reset_mob_target_pos(Vector2)

@export var move_speed: float = 300.0
@export var attack_duration: float = 0.12
@export var attack_cooldown: float = 0.20

# Light debug toggles (low spam)
@export var debug_combat: bool = false
@export var debug_layers: bool = false
@export var debug_input: bool = true

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var health: Health = $Health
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var melee_hitbox: Hitbox = $Hitbox

var _can_attack: bool = true
var is_alive: bool = true
var _last_layer: int = -999
enum Facing { RIGHT, LEFT }
var facing: int = Facing.RIGHT

var _attacking: bool = false

func _ready() -> void:
	add_to_group("player")
	GameConfig.setup_player_body(self)

	if health == null:
		push_error("[Player] Missing $Health")
	else:
		health.died.connect(_on_died)

	if hurtbox == null:
		push_error("[Player] Missing $Hurtbox")

	if melee_hitbox == null:
		push_error("[Player] Missing $Hitbox")
	else:
		melee_hitbox.set_active(false)

	if debug_layers and not LevelManager.layer_changed.is_connected(_on_layer_changed):
		LevelManager.layer_changed.connect(_on_layer_changed)
	_on_layer_changed(LevelManager.current_layer)

func _exit_tree() -> void:
	if debug_layers and LevelManager.layer_changed.is_connected(_on_layer_changed):
		LevelManager.layer_changed.disconnect(_on_layer_changed)

func get_hurt_sfx_key() -> StringName:
	return &"player_hurt"

func _physics_process(_delta: float) -> void:
	if not is_alive:
		return
	_handle_layer_hotkeys()
	_handle_movement()

func _unhandled_input(event: InputEvent) -> void:
	if not debug_input:
		return

	if event is InputEventMouseButton and event.pressed:
		var mb := event as InputEventMouseButton
		print("[Input] Mouse pressed btn=", mb.button_index, " pos=", mb.position)

	if event.is_action_pressed("attack"):
		print("[Input] action attack pressed (unhandled_input)")
		try_attack()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		print("[Input] action attack pressed (_input)")
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

func _handle_movement() -> void:
	var raw := Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)

	var input := raw.normalized()

	velocity = input * move_speed
	move_and_slide()

	# Don't override attack anim while attacking
	if _attacking:
		return

	# Update facing from dominant axis when there is input.
	# - If moving mostly horizontally -> facing follows x
	# - If moving vertical-only -> keep last facing
	# - If diagonal -> dominant axis decides (x wins if |x| >= |y|)
	if raw.length() > 0.01:
		if abs(raw.x) >= abs(raw.y) and abs(raw.x) > 0.01:
			facing = Facing.RIGHT if raw.x > 0.0 else Facing.LEFT

		# Play walk animation if moving at all
		_play_anim("walk_right" if facing == Facing.RIGHT else "walk_left")
	else:
		# No movement -> idle by facing
		_play_anim("idle_right" if facing == Facing.RIGHT else "idle_left")

### Combat and death ###

func try_attack() -> void:
	SoundManager.play_from(self, &"player_swing", 0.95, 1.05, -2.0)
	if debug_combat or debug_input:
		print("[Player] try_attack called. alive=", is_alive,
			" layer=", LevelManager.current_layer,
			" can_attack=", _can_attack,
			" attacking=", _attacking)

	if not is_alive:
		return
	if not _can_attack:
		if debug_combat or debug_input:
			print("[Player] blocked: cooldown")
		return
	if melee_hitbox == null:
		push_error("[Player] Tried to attack but melee_hitbox is null.")
		return

	_can_attack = false
	_attacking = true

	# Always play the animation
	_play_anim("attack_right" if facing == Facing.RIGHT else "attack_left")

	# Only do damage if mask is ON (not MASK_OFF)
	var can_damage := LevelManager.current_layer != LevelManager.Layer.MASK_OFF
	if can_damage:
		melee_hitbox.set_active(true)
	else:
		melee_hitbox.set_active(false)

	if debug_combat:
		print("[Player] attack start (damage=", can_damage, ")")

	await get_tree().create_timer(attack_duration).timeout
	if not is_alive or not is_inside_tree():
		return

	# Always turn off after window
	melee_hitbox.set_active(false)

	_attacking = false

	# Return to locomotion
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

	if debug_combat:
		print("[Player] respawned")

func _on_died() -> void:
	is_alive = false
	_attacking = false
	_can_attack = false
	if melee_hitbox:
		melee_hitbox.set_active(false)
	velocity = Vector2.ZERO

	if debug_combat:
		print("[Player] died")
	
	_play_anim("idle_right" if facing == Facing.RIGHT else "idle_left")

	died.emit() # REQUIRED so GameRoot respawns

### Light debug ###

func _on_layer_changed(layer: int) -> void:
	if not debug_layers:
		return
	if layer == _last_layer:
		return
	_last_layer = layer
	print("[Player] layer=", layer)

func _play_anim(name: String) -> void:
	if anim == null:
		return
	if anim.current_animation == name and anim.is_playing():
		return
	anim.play(name)
