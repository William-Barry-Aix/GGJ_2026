extends Node

enum Faction { PLAYER, ENEMY}

# Godot uses bitmasks (layer index starts at 0)
const LAYER_HURTBOX := 1 << 3  # layer 4
const LAYER_HITBOX  := 1 << 4  # layer 5
