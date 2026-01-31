extends CharacterBody2D

@onready var nav2d := %NavigationAgent2D

#const bolzeur_projectile := preload("res://scenes/Projectiles/bolzeur_projectile.tscn")
#const base_level := preload("res://scenes/levels/base_level.tscn")

@export var speed := 60

const CHARGING_TIME = 3.0
const CHASING_TIME = 5.0
const RESTING_TIME = 1.0
const PROJECTILES_NBR = 25.0

enum bolzeur_state {idle, chasing, charging, resting}

var cur_state := bolzeur_state.charging
var phase_timer := 0.0

signal bolzeur_attack(pos,projectiles_nbr)

func _physics_process(delta: float) -> void:
	phase_timer += delta
	update_timer()
	match cur_state:
		bolzeur_state.idle:
			return
		bolzeur_state.chasing:
			navigate(delta)
		bolzeur_state.charging:
			charging()
		bolzeur_state.resting:
			resting()

# For debug purposes
func manual_navigation() -> void:
	if Input.is_action_just_pressed("left_click"):
		nav2d.target_position = get_global_mouse_position()

func navigate(delta: float) -> void:
	if nav2d.is_navigation_finished():
		return
	var next_path_position : Vector2 = nav2d.get_next_path_position()
	var new_velocity : Vector2 = global_position.direction_to(next_path_position) * speed
	position += new_velocity * delta
	rotation = new_velocity.angle()

func charging():
	pass

func resting():
	pass

func send_attack():
	print("Sending attack!")
	bolzeur_attack.emit(position, PROJECTILES_NBR)

func update_timer():
	if cur_state == bolzeur_state.charging && phase_timer >= CHARGING_TIME:
		print("Charging done!")
		cur_state = bolzeur_state.resting
		phase_timer = 0.0
		send_attack()
	elif cur_state == bolzeur_state.chasing && phase_timer >= CHASING_TIME:
		print("Chasing done!")
		cur_state = bolzeur_state.charging
		phase_timer = 0.0
	elif cur_state == bolzeur_state.resting && phase_timer >= RESTING_TIME:
		print("Resting done!")
		cur_state = bolzeur_state.chasing
		phase_timer = 0.0

func _on_player_reset_mob_target_pos(new_target : Vector2):
	nav2d.target_position = new_target
