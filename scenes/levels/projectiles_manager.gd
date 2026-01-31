extends Node2D

const bolzeur_projectile := preload("res://scenes/Projectiles/bolzeur_projectile.tscn")


func bolzeur_attack(bolzeur_pos : Vector2, projectiles_nbr : float):
	print("bolzeur_attack_trigger!")
	var projectile_dir := Vector2(1,0)
	var angle := 2*PI/projectiles_nbr
	var i := 0
	while i < projectiles_nbr:
		var new_projectile = bolzeur_projectile.instantiate()
		new_projectile.position = bolzeur_pos
		new_projectile.direction = projectile_dir
		projectile_dir = projectile_dir.rotated(angle)
		add_child(new_projectile)
		i += 1
