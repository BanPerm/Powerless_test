extends Node

# --- Groups ---
const GROUP_PLAYER := "player"
const GROUP_ENEMY := "enemy"
const GROUP_OCCLUDER := "occluder"
const GROUP_NAV := "nav_source"

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

# --- Wall ---
const WALL_HEIGHT := 3.0
const WALL_THICKNESS := 0.3
const WALL_CORNER_EXTENSION := 0.15
const FLOOR_MARGIN := 0.6
