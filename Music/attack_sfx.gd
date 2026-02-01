extends Node

@onready var audio = $AudioStreamPlayer

@onready var sound_1 = preload("res://SFX/Io/sword/sword1.mp3")
@onready var sound_2 = preload("res://SFX/Io/sword/sword2.mp3")
@onready var sound_3 = preload("res://SFX/Io/sword/sword3.mp3")

var sounds : Array

func _ready():
	# randomize to make sure our random numbers are always random
	randomize() 
	# an array of all sounds
	sounds = [ sound_1, sound_2, sound_3 ] 
	# play a random sound 

func _play_random_sound():
	# get a random number between 0 and 3
	var sound_index = randi() % 3
	# get a sound with random index
	var sound = sounds[sound_index] 
	# set the sound to the audio stream player
	audio.stream = sound 
	# play the sound
	audio.play()
