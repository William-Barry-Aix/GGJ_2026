extends CharacterBody2D
class_name Player

@export var move_speed: float = 300.0

signal reset_mob_target_pos(Vector2)

func _physics_process(delta: float) -> void:
	_handle_movement(delta)

func _handle_movement(delta: float) -> void:
	var input = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized()
	
	if input != Vector2.ZERO:
		emit_signal("reset_mob_target_pos", position)
	velocity = input * move_speed
	move_and_slide()
