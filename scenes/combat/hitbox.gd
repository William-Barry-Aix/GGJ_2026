extends Area2D
class_name Hitbox

@export var damage: int = 10
@export var debug_print: bool = true

@export var active: bool = false:
	set(value):
		active = value
		monitoring = value
		if value:
			_hit_this_activation.clear()

@export var target_group: StringName = &""  # "player" or "mob"; empty = any hurtbox except self

var _hit_this_activation: Dictionary = {}

func _ready() -> void:
	print("[Hitbox] READY path=", get_path(), " owner=", owner, " target_group=", target_group)

	GameConfig.setup_hitbox(self)
	monitoring = active
	area_entered.connect(_on_area_entered)

	if debug_print:
		print("[Hitbox] ready name=", name,
			" layer=", collision_layer,
			" mask=", collision_mask,
			" active=", active,
			" target_group=", target_group)

func set_active(v: bool) -> void:
	active = v
	monitoring = v
	if v:
		_hit_this_activation.clear()
	if debug_print:
		print("[Hitbox] set_active(", v, ") monitoring=", monitoring)

func _on_area_entered(area: Area2D) -> void:
	print("[Hitbox] ENTER path=", get_path(), " owner=", owner, " target_group=", target_group)

	if debug_print:
		print("[Hitbox] area_entered -> ", area.name, " type=", area.get_class(),
			" groups=", area.get_groups())

	if not active:
		if debug_print:
			print("[Hitbox] ignored: not active")
		return

	if not area.is_in_group("hurtbox"):
		if debug_print:
			print("[Hitbox] ignored: not a hurtbox")
		return

	var my_root := _get_entity_root(self)
	var other_root := _get_entity_root(area)

	if debug_print:
		print("[Hitbox] my_root=", my_root.name, " other_root=", other_root.name)

	# Prevent self-hit
	if my_root == other_root:
		if debug_print:
			print("[Hitbox] ignored: self-hit")
		return

	# Group filter (player vs mob)
	if target_group != &"" and not other_root.is_in_group(target_group):
		if debug_print:
			print("[Hitbox] ignored: target_group mismatch. need=", target_group, " other groups=", other_root.get_groups())
		return

	# One hit per activation per target
	var id := area.get_instance_id()
	if _hit_this_activation.has(id):
		if debug_print:
			print("[Hitbox] ignored: already hit this hurtbox this activation")
		return
	_hit_this_activation[id] = true

	if area.has_method("receive_hit"):
		if debug_print:
			print("[Hitbox] APPLY damage=", damage, " -> ", other_root.name)
		area.call("receive_hit", damage, my_root)
	else:
		if debug_print:
			print("[Hitbox] ERROR: hurtbox has no receive_hit")

func _get_entity_root(n: Node) -> Node:
	var cur: Node = n
	while cur != null:
		# Convention: entity roots are CharacterBody2D (Player, BaseMob)
		if cur is CharacterBody2D:
			return cur
		cur = cur.get_parent()
	return n
