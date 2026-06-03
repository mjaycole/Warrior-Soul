#Handles controlling the player stats and making those available

extends Resource
class_name  PlayerStat

# Signals
signal player_stats_changed

# Handles player physical stats
@export var max_health: float = 100
