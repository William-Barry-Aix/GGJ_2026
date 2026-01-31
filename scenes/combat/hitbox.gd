extends Area2D
class_name Hitbox

@export var damage: int = 10
@export var active: bool = false:
	set(value):
		active = value
		monitoring = value
		if value:
			_hit_this_activation.clear()

# Optional: avoid hitting the same hurtbox multiple times during one swing
var _hit_this_activation: Dictionary = {}

func _ready() -> void:
	collision_layer = GameConfig.LAYER_HITBOX
	collision_mask  = GameConfig.LAYER_HURTBOX
	monitoring = active
	area_entered.connect(_on_area_entered)

func set_active(v: bool) -> void:
	active = v
	monitoring = v
	if v:
		_hit_this_activation.clear()

func _on_area_entered(area: Area2D) -> void:
	if not active:
		return
	if not area.is_in_group("hurtbox"):
		return

	var my_root := _get_entity_root(self)
	var other_root := _get_entity_root(area)

	# Prevent self-hit
	if my_root == other_root:
		return

	# One hit per activation per target (still useful)
	if _hit_this_activation.has(area.get_instance_id()):
		return
	_hit_this_activation[area.get_instance_id()] = true

	if area.has_method("receive_hit"):
		area.call("receive_hit", damage, my_root)


func _get_entity_root(n: Node) -> Node:
	var cur: Node = n
	while cur != null:
		# Convention: entity roots are CharacterBody2D (Player, BaseMob)
		if cur is CharacterBody2D:
			return cur
		cur = cur.get_parent()
	return n
