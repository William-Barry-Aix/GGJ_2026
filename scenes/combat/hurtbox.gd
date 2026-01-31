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

	health.apply_damage(damage)

	if damage <= 0:
		return

	var root = _get_entity_root()
	if root == null:
		return

	# Ask the root what sound to use
	var key: StringName = &""
	if root.has_method("get_hurt_sfx_key"):
		key = root.call("get_hurt_sfx_key")
	elif root.is_in_group("player"):
		key = &"player_hurt"
	elif root.is_in_group("mob"):
		key = &"mob_hurt_generic"

	if key != &"":
		SoundManager.play_from(root, key, 0.98, 1.02, 0.0)

func _get_entity_root() -> Node2D:
	var cur: Node = self
	while cur:
		if cur is CharacterBody2D:
			return cur as Node2D
		cur = cur.get_parent()
	return null


#func receive_hit(damage: int, source: Node = null) -> void:
	##print("[Hurtbox] receive_hit dmg=", damage, " source=", source)
	#if health == null:
		#return
	#if debug_print:
		#print("[Hurtbox] Took ", damage, " from ", source)
	#health.apply_damage(damage)
