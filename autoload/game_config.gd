extends Node

# ---- Physics Body layers (CharacterBody2D) ----
# Choose free layer numbers and stick to them
const BODY_WORLD  := 1 << 0   # Layer 1 (walls/tile collisions, etc.)
const BODY_PLAYER := 1 << 1   # Layer 2
const BODY_MOB    := 1 << 2   # Layer 3

# ---- Combat Area layers (Area2D) ----
const AREA_HURTBOX := 1 << 3  # Layer 4
const AREA_HITBOX  := 1 << 4  # Layer 5

# ---- Helper presets ----
static func setup_player_body(body: CollisionObject2D) -> void:
	body.collision_layer = BODY_PLAYER
	body.collision_mask  = BODY_WORLD | BODY_MOB

static func setup_mob_body(body: CollisionObject2D) -> void:
	body.collision_layer = BODY_MOB
	body.collision_mask  = BODY_WORLD | BODY_PLAYER | BODY_MOB

static func setup_hurtbox(area: Area2D) -> void:
	area.collision_layer = AREA_HURTBOX
	area.collision_mask  = AREA_HITBOX

static func setup_hitbox(area: Area2D) -> void:
	area.collision_layer = AREA_HITBOX
	area.collision_mask  = AREA_HURTBOX
