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

@onready var health: Health = $Health
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var melee_hitbox: Hitbox = $Hitbox

var _can_attack: bool = true
var is_alive: bool = true
var _last_layer: int = -999

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

func _physics_process(_delta: float) -> void:
	if not is_alive:
		return
	_handle_layer_hotkeys()
	_handle_movement()

func _unhandled_input(event: InputEvent) -> void:
	if not is_alive:
		return
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

func _handle_movement() -> void:
	var input := Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized()
	velocity = input * move_speed
	move_and_slide()

### Combat and death ###

func try_attack() -> void:
	if not is_alive:
		return

	if LevelManager.current_layer == LevelManager.Layer.MASK_OFF:
		return

	if not _can_attack:
		return

	if melee_hitbox == null:
		push_error("[Player] Tried to attack but melee_hitbox is null.")
		return

	_can_attack = false
	melee_hitbox.set_active(true)

	if debug_combat:
		print("[Player] attack start")

	await get_tree().create_timer(attack_duration).timeout
	if not is_alive or not is_inside_tree():
		return

	melee_hitbox.set_active(false)

	if debug_combat:
		print("[Player] attack end")

	await get_tree().create_timer(attack_cooldown).timeout
	if not is_alive or not is_inside_tree():
		return

	_can_attack = true

func reset_after_respawn() -> void:
	is_alive = true
	health.reset_full()
	_can_attack = true
	if melee_hitbox:
		melee_hitbox.set_active(false)

	if debug_combat:
		print("[Player] respawned")

func _on_died() -> void:
	is_alive = false
	_can_attack = false
	if melee_hitbox:
		melee_hitbox.set_active(false)
	velocity = Vector2.ZERO

	if debug_combat:
		print("[Player] died")

	died.emit() # REQUIRED so GameRoot respawns

### Light debug ###

func _on_layer_changed(layer: int) -> void:
	if not debug_layers:
		return
	if layer == _last_layer:
		return
	_last_layer = layer
	print("[Player] layer=", layer)
