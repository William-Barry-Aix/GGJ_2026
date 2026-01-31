extends BaseMob
class_name BolzeurMob

@onready var nav2d: NavigationAgent2D = $NavigationAgent2D

const CHARGING_TIME = 3.0
const CHASING_TIME  = 5.0
const RESTING_TIME  = 1.0
const PROJECTILES_NBR = 25

enum State { idle, chasing, charging, resting }
var cur_state: int = State.charging
var phase_timer := 0.0

signal request_radial_shot(origin: Vector2, count: int)



func _ready() -> void:
	super._ready()

	var p := get_tree().get_first_node_in_group("player") as Node2D
	if p:
		set_target(p)

func _physics_process(delta: float) -> void:
	if not is_alive:
		return

	phase_timer += delta
	_update_timer()

	match cur_state:
		State.idle:
			return
		State.chasing:
			_chase(delta)
		State.charging:
			pass
		State.resting:
			pass

func _chase(delta: float) -> void:
	if target == null:
		return
	nav2d.target_position = target.global_position
	var next_pos := nav2d.get_next_path_position()
	var dir := (next_pos - global_position).normalized()
	velocity = dir * move_speed
	move_and_slide()

func _send_attack() -> void:
	request_radial_shot.emit(global_position, PROJECTILES_NBR)

func send_attack():
	request_radial_shot.emit(global_position, int(PROJECTILES_NBR))

func _update_timer() -> void:
	if cur_state == State.charging and phase_timer >= CHARGING_TIME:
		cur_state = State.resting
		phase_timer = 0.0
		_send_attack()
	elif cur_state == State.chasing and phase_timer >= CHASING_TIME:
		cur_state = State.charging
		phase_timer = 0.0
	elif cur_state == State.resting and phase_timer >= RESTING_TIME:
		cur_state = State.chasing
		phase_timer = 0.0
