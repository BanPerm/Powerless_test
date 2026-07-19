extends Node

# --- Groups ---
const GROUP_PLAYER := "player"
const GROUP_ENEMY := "enemy"
const GROUP_OCCLUDER := "occluder"

# --- Physique ---
const GRAVITY := 9.8
const GROUND_Y := 0.0

# --- Combat par défaut ---
const DEFAULT_INVINCIBILITY_PLAYER := 0.5
const DEFAULT_INVINCIBILITY_ENEMY := 0.05

# --- Input actions ---
const ACTION_DASH := "dash"
const ACTION_ATTACK_PRIMARY := "attack_primary"
const ACTION_ATTACK_SECONDARY := "attack_secondary"
const ACTION_ATTACK_AREA := "attack_area"
const ACTION_ATTACK_ORB := "attack_orb"
