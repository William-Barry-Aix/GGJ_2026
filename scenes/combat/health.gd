extends Node
class_name Health

signal changed(current: int, max: int)
signal died()

@export var max_health: int = 100
@export var invuln_seconds: float = 0.15

var current_health: int
var _invuln_until_ms: int = 0

func _ready() -> void:
	current_health = max_health
	changed.emit(current_health, max_health)

func reset_full() -> void:
	current_health = max_health
	_invuln_until_ms = 0
	changed.emit(current_health, max_health)

func can_take_damage() -> bool:
	return Time.get_ticks_msec() >= _invuln_until_ms and current_health > 0

func apply_damage(amount: int) -> void:
	if amount <= 0:
		return
	if not can_take_damage():
		return

	current_health = max(0, current_health - amount)
	_invuln_until_ms = Time.get_ticks_msec() + int(invuln_seconds * 1000.0)
	changed.emit(current_health, max_health)

	if current_health == 0:
		died.emit()

func apply_heal(amount: int) -> void:
	if amount <= 0 or current_health <= 0:
		return
	current_health = min(max_health, current_health + amount)
	changed.emit(current_health, max_health)
