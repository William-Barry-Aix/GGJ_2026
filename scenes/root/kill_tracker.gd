extends Node
class_name KillTracker

signal bolzeur_kills_changed(count: int)

var bolzeur_kills: int = 0

func _ready() -> void:
	add_to_group("kill_tracker")

func register_mob(mob: BaseMob) -> void:
	if mob == null:
		return
	if not mob.mob_died.is_connected(_on_mob_died):
		mob.mob_died.connect(_on_mob_died)

func _on_mob_died(mob: BaseMob) -> void:
	if mob.mob_kind == &"bolzeur":
		bolzeur_kills += 1
		bolzeur_kills_changed.emit(bolzeur_kills)
