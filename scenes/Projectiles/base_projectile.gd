extends Area2D
class_name BaseProjectile

@export var speed: float = 420.0
@export var lifetime: float = 2.0

@onready var hitbox: Hitbox = $Hitbox

var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	hitbox.set_active(true)
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	global_position += direction.normalized() * speed * delta
