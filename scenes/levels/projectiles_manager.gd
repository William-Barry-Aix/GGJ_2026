extends Node2D
class_name ProjectileManager

@export var bolzeur_projectile_scene: PackedScene

func spawn_projectile(scene: PackedScene, pos: Vector2, dir: Vector2, speed: float = -1.0) -> void:
	var p := scene.instantiate() as BaseProjectile
	p.global_position = pos
	p.direction = dir
	if speed > 0.0:
		p.speed = speed
	add_child(p)

func radial_shot(scene: PackedScene, pos: Vector2, count: int) -> void:
	if count <= 0:
		return
	var dir := Vector2.RIGHT
	var angle := TAU / float(count)
	for i in count:
		spawn_projectile(scene, pos, dir)
		dir = dir.rotated(angle)

func on_bolzeur_radial(origin: Vector2, count: int) -> void:
	if bolzeur_projectile_scene == null:
		push_error("[ProjectilesManager] bolzeur_projectile_scene not set")
		return
	if count <= 0:
		return

	var dir := Vector2.RIGHT
	var step := TAU / float(count)
	for i in range(count):
		var p := bolzeur_projectile_scene.instantiate()
		p.global_position = origin
		p.direction = dir  # assuming your projectile has `direction`
		add_child(p)
		dir = dir.rotated(step)

#func on_bolzeur_radial(origin: Vector2, count: int) -> void:
	#radial_shot(bolzeur_projectile_scene, origin, count)
