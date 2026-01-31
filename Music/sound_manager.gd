extends Node

# Put all SFX on a dedicated bus named "SFX"
@export var sfx_bus: StringName = &"SFX"

# Simple library: key -> array of streams (variants)
@export var library: Dictionary = {
	"mask_toggle": [],
	"player_swing": [],
	"player_hurt": [],
	"mob_hurt_generic": [],
	"bolzeur_hurt": [],
	"ghost_hurt": [],
	"mob_charge": [],
	"mob_attack": []
}

# Pool so we don't constantly allocate players
@export var pool_size: int = 16
var _pool_2d: Array[AudioStreamPlayer2D] = []
var _pool_ui: Array[AudioStreamPlayer] = []

func _ready() -> void:
	# Prewarm pools
	for i in range(pool_size):
		var p2 := AudioStreamPlayer2D.new()
		p2.bus = sfx_bus
		p2.finished.connect(func(): p2.playing = false) # harmless
		add_child(p2)
		_pool_2d.append(p2)

		var pu := AudioStreamPlayer.new()
		pu.bus = sfx_bus
		pu.finished.connect(func(): pu.playing = false)
		add_child(pu)
		_pool_ui.append(pu)

func play_ui(key: StringName, pitch_min: float = 1.0, pitch_max: float = 1.0, vol_db: float = 0.0) -> void:
	var stream := _pick_stream(key)
	if stream == null:
		return
	var p := _get_free_ui()
	if p == null:
		return
	p.stream = stream
	p.volume_db = vol_db
	p.pitch_scale = randf_range(pitch_min, pitch_max)
	p.play()

func play_at(key: StringName, world_pos: Vector2, pitch_min: float = 1.0, pitch_max: float = 1.0, vol_db: float = 0.0) -> void:
	var stream := _pick_stream(key)
	if stream == null:
		return
	var p := _get_free_2d()
	if p == null:
		return
	p.global_position = world_pos
	p.stream = stream
	p.volume_db = vol_db
	p.pitch_scale = randf_range(pitch_min, pitch_max)
	p.play()

func play_from(node: Node2D, key: StringName, pitch_min: float = 1.0, pitch_max: float = 1.0, vol_db: float = 0.0) -> void:
	if node == null:
		return
	play_at(key, node.global_position, pitch_min, pitch_max, vol_db)

# ------------------------
# Internals
# ------------------------
func _pick_stream(key: StringName) -> AudioStream:
	if not library.has(key):
		push_warning("[SoundManager] Missing key: %s" % key)
		return null
	var arr: Array = library[key]
	if arr.is_empty():
		push_warning("[SoundManager] No streams set for key: %s" % key)
		return null
	return arr[randi() % arr.size()] as AudioStream

func _get_free_2d() -> AudioStreamPlayer2D:
	for p in _pool_2d:
		if not p.playing:
			return p
	return _pool_2d[0] # steal oldest (jam-safe)

func _get_free_ui() -> AudioStreamPlayer:
	for p in _pool_ui:
		if not p.playing:
			return p
	return _pool_ui[0]
