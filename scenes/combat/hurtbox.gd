extends Area2D
class_name Hurtbox

@export var health_path: NodePath
@export var debug_print: bool = false

@onready var health: Health = get_node_or_null(health_path) as Health

func _ready() -> void:
	add_to_group("hurtbox")
	if health == null:
		push_error("[Hurtbox] Missing Health reference. Set health_path in inspector.")

func receive_hit(damage: int, source: Node = null) -> void:
	if health == null:
		return
	if debug_print:
		print("[Hurtbox] Took ", damage, " from ", source)
	health.apply_damage(damage)
