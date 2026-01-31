extends CharacterBody2D

const speed := 8000

var direction : Vector2

func _process(delta):
	velocity = direction * speed * delta
	move_and_slide()
