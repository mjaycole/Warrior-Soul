# The EventBus for the game

extends Node

# Player events
signal player_spawned(player: player_controller)
signal player_died
signal player_health_changed(new_health: float)
signal player_level_up(amount: int)
signal player_stat_increase(stat: String, amount: int)
signal player_perk_increase(stat: String, perk: Perk)

# Enemy events
signal enemy_died(enemy: Node)
signal enemy_spawned(enemy: Node)

# World events
signal world_loaded(world_name: String)
signal world_unloaded

# UI events
signal enter_dialogue
signal exit_dialogue