extends Area2D
class_name Projectile

@export var speed: float = 420.0
@export var lifetime: float = 2.0

@onready var hitbox: Hitbox = $Hitbox

var velocity: Vector2 = Vector2.ZERO

func _ready() -> void:
	hitbox.set_active(true)
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	global_position += velocity * delta
