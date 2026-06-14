#The main resources that references all the other player data resources

extends Resource
class_name PlayerData

@export var inventory: PlayerInventory
@export var stats: PlayerStat
@export var perks: PlayerPerks

func initialize():	
	stats.init_base_stats()
	perks.update_active_perks(stats.current_top_level_stats)

	for perk in perks.active_perks:
		print("Has an active perk! ", perk.perk_name)
		print(perk.perk_name, " is giving ", perk.get_current_effect(), " bonus to ", perk.effect_target)

# When the total stat value (including perks and current bonuses) is needed. The "stat" string to pass is the name of the stat that is being affected (see init_base_stats in PlayerStats)
func get_movement_stat(stat: String) -> float:
	return stats.get_final_movement_stat(stat, perks)