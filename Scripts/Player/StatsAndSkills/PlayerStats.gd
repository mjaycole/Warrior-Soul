#Handles controlling the player stats and making those available

extends Resource
class_name  PlayerStat

# Signals
signal player_stats_changed

@export var player_level: int = 1

@export_group("Top Level Stats")
# This dictionary stores a reference table for all seven top level stats to easily be referenced
@export var current_top_level_stats: Dictionary
@export var base_strength: int
@export var base_precision: int
@export var base_endurance: int
@export var base_agility: int
@export var base_resiliance: int
@export var base_instinct: int
@export var base_luck: int


@export_group("Physical Stats")
# This dictionary stores a reference table for all three physical stats to easily be referenced
@export var current_physical_stats: Dictionary
@export var base_health: float = 100
@export var base_stamina: float = 100
@export var base_mana: float = 100


@export_group("Movement Stats")
# This dictionary stores a reference table for all movement stats to easily be referenced
@export var current_movement_stats: Dictionary
@export var base_walk_speed: float
@export var base_sprint_multiplier: float
@export var base_jump_height: float
@export var base_dash_speed: float
@export var base_push_speed: float

var _initialized: bool = false

# Initialize the dictionaries with their base values
func init_base_stats():
    if _initialized:
        return

    _initialized = true

    current_top_level_stats["strength"] = base_strength
    current_top_level_stats["agility"] = base_agility

    current_physical_stats["health"] = base_health
    current_physical_stats["stamina"] = base_stamina
    current_physical_stats["mana"] = base_mana

    current_movement_stats["speed"] = base_walk_speed
    current_movement_stats["sprint"] = base_sprint_multiplier
    current_movement_stats["jump"] = base_jump_height
    current_movement_stats["dash"] = base_dash_speed
    current_movement_stats["push"] = base_push_speed

# This just returns the base value for a stat
func _get_movement_stat(stat: String) -> float:
    return current_movement_stats[stat]

# Return the final value for a movement stat based on the key, including any active perks that affect that stat key
func get_final_movement_stat(stat: String, perks: PlayerPerks) -> float:
    var base: float = current_movement_stats[stat]
    var effects: Array[float] = perks.get_perk_effects(stat)
    var bonus: float = 0.0
    for effect in effects:
        bonus += effect

    return base * (1.0 + bonus)

# Increases the player level by X amount
func command_increase_player_level(amount: int):
    player_level += amount

# Increases a top level stat by X amount
func command_increase_top_level_stat(stat: String, amount: int):
    if not current_top_level_stats[stat]:
        return
    
    current_top_level_stats[stat] += amount
