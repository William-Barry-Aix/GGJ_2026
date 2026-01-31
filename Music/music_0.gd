extends AudioStreamPlayer2D

#indexage des bus sonores
@onready var music0busindex = AudioServer.get_bus_index("Music0")
@onready var music1busindex = AudioServer.get_bus_index("Music1")
@onready var music2busindex = AudioServer.get_bus_index("Music2")
@onready var music3busindex = AudioServer.get_bus_index("Music3")
@onready var mask_sound = $SFX/mask_sound
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#mute layer 1 et 2 au début
	AudioServer.set_bus_mute(music1busindex, true)
	AudioServer.set_bus_mute(music2busindex, true)
	AudioServer.set_bus_mute(music3busindex, true)

func mute_layer(musicindex):
	if !AudioServer.is_bus_mute(musicindex):
		for n in 10:
			AudioServer.set_bus_volume_linear(musicindex, 1-float(n+1)/10)
			await get_tree().create_timer(0.04).timeout
		AudioServer.set_bus_mute(musicindex, true)

func unmute_layer(musicindex):
	if AudioServer.is_bus_mute(musicindex):
		AudioServer.set_bus_mute(musicindex, false)
		for n in 10:
			AudioServer.set_bus_volume_linear(musicindex, float(n+1)/10)
			await get_tree().create_timer(0.04).timeout

func change_layer_music(layer: int) -> void:
	mask_sound.play()
	if layer == 1:
		mute_layer(music1busindex)
		mute_layer(music2busindex)
		mute_layer(music3busindex)
	if layer == 2:
		unmute_layer(music1busindex)
		mute_layer(music2busindex)
		mute_layer(music3busindex)
	if layer == 3:
		mute_layer(music1busindex)
		unmute_layer(music2busindex)
		mute_layer(music3busindex)
	if layer == 4:
		mute_layer(music1busindex)
		mute_layer(music2busindex)
		unmute_layer(music3busindex)
	if layer == 5:
		unmute_layer(music1busindex)
		unmute_layer(music2busindex)
		unmute_layer(music3busindex)
