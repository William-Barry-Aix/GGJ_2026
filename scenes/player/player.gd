extends CharacterBody2D
class_name Player

@export var move_speed: float = 300.0

func _physics_process(delta: float) -> void:
	_handle_layer_hotkeys()
	_handle_movement(delta)

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
