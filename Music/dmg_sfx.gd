extends Node

@onready var audio = $AudioStreamPlayer

@onready var sound_1 = preload("res://SFX/Io/damage/damage1.mp3")
@onready var sound_2 = preload("res://SFX/Io/damage/damage2.mp3")
@onready var sound_3 = preload("res://SFX/Io/damage/damage3.mp3")
@onready var sound_4 = preload("res://SFX/Io/damage/damage4.mp3")
@onready var sound_5 = preload("res://SFX/Io/damage/damage5.mp3")
@onready var sound_6 = preload("res://SFX/Io/damage/damage6.mp3")
@onready var sound_7 = preload("res://SFX/Io/damage/damage7.mp3")
@onready var sound_8 = preload("res://SFX/Io/damage/damage8.mp3")

var sounds : Array

func _ready():
	# randomize to make sure our random numbers are always random
	randomize() 
	# an array of all sounds
	sounds = [ sound_1, sound_2, sound_3, sound_4, sound_5, sound_6, sound_7, sound_8 ] 
	# play a random sound 


func _play_random_sound():
	# get a random number between 0 and 3
	var sound_index = randi() % 8 
	# get a sound with random index
	var sound = sounds[sound_index] 
	# set the sound to the audio stream player
	audio.stream = sound 
	# play the sound
	audio.play() 
