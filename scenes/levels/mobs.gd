extends Node2D

const BOLZEUR_NODE := preload("res://scenes/mobs/bolzeur_mob.tscn")

@onready var projectiles_manager := %ProjectilesManager

func _ready():
	_bolzeur_spawn(Vector2(-200, 200))
	pass

func _bolzeur_spawn(pos):
	var new_bolzeur = BOLZEUR_NODE.instantiate()
	new_bolzeur.position = pos

	new_bolzeur.request_radial_shot.connect(projectiles_manager.on_bolzeur_radial)

	add_child(new_bolzeur)
