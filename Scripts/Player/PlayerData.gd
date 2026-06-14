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

		if stats.movement_stats_affect_target_keys.has(perk.effect_target):
			stats.inject_perk_movement_bonuses(perk.effect_target, perk.get_current_effect())
