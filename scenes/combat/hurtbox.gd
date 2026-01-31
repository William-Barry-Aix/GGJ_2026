extends Area2D
class_name Hurtbox

@export var health_path: NodePath
@onready var health: Health = get_node_or_null(health_path) as Health

@export var debug_print: bool = false

func _ready() -> void:
	add_to_group("hurtbox")
	GameConfig.setup_hurtbox(self)
	if health == null:
		push_error("[Hurtbox] Missing Health reference. Set health_path in inspector.")

func receive_hit(damage: int, source: Node = null) -> void:
	print("[Hurtbox] receive_hit dmg=", damage, " source=", source)
	if health == null:
		return
	if debug_print:
		print("[Hurtbox] Took ", damage, " from ", source)
	health.apply_damage(damage)
