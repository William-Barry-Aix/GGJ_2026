extends BaseMob
class_name TestMeleeMob

@export var attack_range: float = 42.0
@export var attack_windup: float = 0.08
@export var attack_active: float = 0.10
@export var attack_cooldown: float = 0.60

@onready var melee_hitbox: Hitbox = $Hitbox

var _can_attack: bool = true

func _ready() -> void:
	super._ready()
	melee_hitbox.set_active(false)

	# Auto-target player (simple jam approach)
	var p := get_tree().get_first_node_in_group("player") as Node2D
	if p:
		set_target(p)

func _physics_process(delta: float) -> void:
	if target == null:
		return

	var dist := global_position.distance_to(target.global_position)

	if dist > attack_range:
		_move_towards_target()
		return

	# In range: stop and swing
	velocity = Vector2.ZERO
	move_and_slide()

	if _can_attack:
		_attack()

func _attack() -> void:
	_can_attack = false

	# Optional: play anim / telegraph during windup
	await get_tree().create_timer(attack_windup).timeout

	melee_hitbox.set_active(true)
	await get_tree().create_timer(attack_active).timeout
	melee_hitbox.set_active(false)

	await get_tree().create_timer(attack_cooldown).timeout
	_can_attack = true
