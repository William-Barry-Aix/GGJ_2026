extends CharacterBody2D

const speed := 700

var direction := Vector2(0,0)

func _process(delta):
	var velocity = direction * speed * delta
	move_and_slide()
