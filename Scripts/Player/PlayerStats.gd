#Handles controlling the player stats and making those available

extends Resource
class_name  PlayerStat

# Signals
signal player_stats_changed

# Handles player physical stats
@export var max_health: float = 100
@export var max_stamina: float = 100
@export var max_mana: float = 100

@export var current_walk_speed: float
@export var current_sprint_multiplier: float
@export var current_jump_height: float
@export var current_dash_speed: float
@export var current_push_speed: float


