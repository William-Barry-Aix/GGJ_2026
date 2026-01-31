extends Node2D

const BOLZEUR_NODE := preload("res://scenes/mobs/bolzeur.tscn")

@onready var projectiles_manager := %ProjectilesManager

func _ready():
	_bolzeur_spawn(Vector2(-200, 200))

func _bolzeur_spawn(pos):
	var new_bolzeur = BOLZEUR_NODE.instantiate()
	new_bolzeur.position = pos
	new_bolzeur.bolzeur_attack.connect(projectiles_manager.bolzeur_attack)
	add_child(new_bolzeur)
	
