extends Area2D
class_name Hurtbox

@export var health_path: NodePath
@onready var health: Health = get_node_or_null(health_path) as Health

@export var debug_print: bool = false

func _ready() -> void:
	add_to_group("hurtbox")
	GameConfig.setup_hurtbox(self)

	if debug_print:
		print("[Hurtbox] ready name=", name,
			" owner=", get_parent().name,
			" layer=", collision_layer,
			" mask=", collision_mask,
			" health_path=", health_path)

	if health == null:
		push_error("[Hurtbox] Missing Health reference. Set health_path in inspector.")

func receive_hit(damage: int, source: Node = null) -> void:
	if debug_print:
		print("[Hurtbox] receive_hit damage=", damage,
			" source=", (source.name if source else "null"),
			" health_null=", (health == null))

	if health == null:
		return

	health.apply_damage(damage)

	if debug_print:
		print("[Hurtbox] after apply_damage current=", health.current_health, " max=", health.max_health)
