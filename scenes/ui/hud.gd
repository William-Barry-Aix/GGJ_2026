extends Control
class_name HUD

@export var debug_print: bool = false

@onready var health_bar: ProgressBar = $HealthBar
@onready var bottom_anchor: Control = $BottomAnchor
@onready var bottom_bar: PanelContainer = $BottomAnchor/BottomBar
@onready var hbox: HBoxContainer = $BottomAnchor/BottomBar/HBox

# Demo values (replace later with Player-driven values)
var current_health: float = 80.0
var max_health: float = 100.0


func _ready() -> void:
	# HUD fills screen
	set_anchors_preset(Control.PRESET_FULL_RECT)
	offset_left = 0
	offset_top = 0
	offset_right = 0
	offset_bottom = 0

	# Validate nodes (prevents null crashes)
	if health_bar == null:
		push_error("[HUD] Missing HealthBar node.")
	if bottom_anchor == null:
		push_error("[HUD] Missing BottomAnchor node.")
	if bottom_bar == null:
		push_error("[HUD] Missing BottomBar node (expected at BottomAnchor/BottomBar).")
	if hbox == null:
		push_error("[HUD] Missing HBox node (expected at BottomAnchor/BottomBar/HBox).")
		return

	_setup_healthbar_layout()
	_apply_healthbar_style()
	_update_health_ui()

	_setup_bottom_anchor_layout()
	_apply_bottom_bar_style()

	# Listen for layer changes
	if not LevelManager.layer_changed.is_connected(_on_layer_changed):
		LevelManager.layer_changed.connect(_on_layer_changed)

	_rebuild_layer_toolbar()
	_on_layer_changed(LevelManager.current_layer)


func _exit_tree() -> void:
	if LevelManager.layer_changed.is_connected(_on_layer_changed):
		LevelManager.layer_changed.disconnect(_on_layer_changed)


# -------------------------
# Public API
# -------------------------
func set_health(value: float, max_value: float = -1.0) -> void:
	if max_value > 0.0:
		max_health = max_value
	current_health = clamp(value, 0.0, max_health)
	_update_health_ui()


# -------------------------
# Health bar
# -------------------------
func _setup_healthbar_layout() -> void:
	if health_bar == null:
		return

	health_bar.custom_minimum_size = Vector2(420, 28)
	health_bar.show_percentage = false

	# Top-left placement
	health_bar.anchor_left = 0.0
	health_bar.anchor_top = 0.0
	health_bar.anchor_right = 0.0
	health_bar.anchor_bottom = 0.0
	health_bar.offset_left = 24
	health_bar.offset_top = 24
	health_bar.offset_right = 24 + 420
	health_bar.offset_bottom = 24 + 28


func _apply_healthbar_style() -> void:
	if health_bar == null:
		return

	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.12, 0.12, 0.12, 0.85)
	bg.corner_radius_top_left = 8
	bg.corner_radius_top_right = 8
	bg.corner_radius_bottom_left = 8
	bg.corner_radius_bottom_right = 8

	var fill := StyleBoxFlat.new()
	fill.bg_color = Color(0.25, 0.9, 0.25, 0.95)
	fill.corner_radius_top_left = 8
	fill.corner_radius_top_right = 8
	fill.corner_radius_bottom_left = 8
	fill.corner_radius_bottom_right = 8

	health_bar.add_theme_stylebox_override("background", bg)
	health_bar.add_theme_stylebox_override("fill", fill)


func _update_health_ui() -> void:
	if health_bar == null:
		return
	health_bar.min_value = 0.0
	health_bar.max_value = max_health
	health_bar.value = current_health


# -------------------------
# Bottom bar layout
# -------------------------
func _setup_bottom_anchor_layout() -> void:
	# BottomAnchor is a full-width strip at the bottom
	bottom_anchor.anchor_left = 0.0
	bottom_anchor.anchor_right = 1.0
	bottom_anchor.anchor_top = 1.0
	bottom_anchor.anchor_bottom = 1.0

	# Height of the bottom UI band
	bottom_anchor.offset_left = 0
	bottom_anchor.offset_right = 0
	bottom_anchor.offset_top = -140
	bottom_anchor.offset_bottom = 0

	# BottomBar should NOT be stretched — it should size to content and be centered.
	bottom_bar.anchor_left = 0.5
	bottom_bar.anchor_right = 0.5
	bottom_bar.anchor_top = 0.5
	bottom_bar.anchor_bottom = 0.5
	bottom_bar.offset_left = 0
	bottom_bar.offset_right = 0
	bottom_bar.offset_top = 0
	bottom_bar.offset_bottom = 0

	# Make the HBox center its children nicely
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 14)


func _apply_bottom_bar_style() -> void:
	var panel := StyleBoxFlat.new()
	panel.bg_color = Color(0.08, 0.08, 0.08, 0.75)
	panel.corner_radius_top_left = 16
	panel.corner_radius_top_right = 16
	panel.corner_radius_bottom_left = 16
	panel.corner_radius_bottom_right = 16
	panel.content_margin_left = 18
	panel.content_margin_right = 18
	panel.content_margin_top = 14
	panel.content_margin_bottom = 14

	bottom_bar.add_theme_stylebox_override("panel", panel)


# -------------------------
# Layer toolbar
# -------------------------
func _on_layer_changed(layer: int) -> void:
	if debug_print:
		print("[HUD] layer changed -> ", layer)

	# Highlight selection by disabling selected button
	for child in hbox.get_children():
		var b := child as Button
		if b == null:
			continue
		var btn_layer := int(b.get_meta("layer_id", 0))
		b.disabled = (btn_layer == layer)


func _rebuild_layer_toolbar() -> void:
	# Clear old
	for c in hbox.get_children():
		c.queue_free()

	var layer_dict: Dictionary = LevelManager.Layer

	# Convert to sorted entries by id
	var entries: Array = []
	for name in layer_dict.keys():
		entries.append({ "name": str(name), "id": int(layer_dict[name]) })
	entries.sort_custom(func(a, b): return a["id"] < b["id"])

	for e in entries:
		var layer_id: int = e["id"]
		var layer_name: String = e["name"]

		var btn := Button.new()
		btn.custom_minimum_size = Vector2(78, 78)  # bigger
		btn.add_theme_font_size_override("font_size", 22)
		btn.text = str(layer_id)
		btn.tooltip_text = layer_name
		btn.focus_mode = Control.FOCUS_NONE

		btn.set_meta("layer_id", layer_id)
		_apply_layer_button_style(btn, layer_id)

		btn.pressed.connect(func():
			LevelManager.set_layer(layer_id)
		)

		hbox.add_child(btn)

	# Let layout settle so BottomBar sizes to content
	call_deferred("_recenter_bottom_bar")


func _recenter_bottom_bar() -> void:
	# With anchors at 0.5/0.5 and offsets 0, PanelContainer will size to minimum.
	# But we still want to force a layout pass so its minimum size is computed.
	hbox.queue_sort()
	await get_tree().process_frame
	bottom_bar.queue_sort()


func _apply_layer_button_style(btn: Button, layer_id: int) -> void:
	var col := _color_for_layer(layer_id)

	var normal := StyleBoxFlat.new()
	normal.bg_color = col
	normal.corner_radius_top_left = 10
	normal.corner_radius_top_right = 10
	normal.corner_radius_bottom_left = 10
	normal.corner_radius_bottom_right = 10

	var hover := normal.duplicate()
	hover.bg_color = col.lightened(0.10)

	var pressed := normal.duplicate()
	pressed.bg_color = col.darkened(0.12)

	var disabled := normal.duplicate()
	disabled.bg_color = col.darkened(0.25)

	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", pressed)
	btn.add_theme_stylebox_override("disabled", disabled)


func _color_for_layer(layer: int) -> Color:
	match layer:
		LevelManager.Layer.MASK_OFF:
			return Color(0.85, 0.85, 0.85, 1.0)
		LevelManager.Layer.RED:
			return Color(1.0, 0.55, 0.55, 1.0)
		LevelManager.Layer.GREEN:
			return Color(0.55, 1.0, 0.55, 1.0)
		LevelManager.Layer.BLUE:
			return Color(0.55, 0.70, 1.0, 1.0)
		_:
			return Color(1, 1, 1, 1)
