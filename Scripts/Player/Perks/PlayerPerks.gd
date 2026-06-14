# This handles storing the player's currently perk selections. Each stat has a perk for the base and for each tier

extends Resource
class_name PlayerPerks

# Signals
signal player_perks_changed

@export var active_perks: Array[Perk]

@export var strength_perks: Array[Perk]
@export var precision_perks: Array[Perk]
@export var endurance_perks: Array[Perk]
@export var agility_perks: Array[Perk]


func update_active_perks(stats: Dictionary):
	active_perks.clear()

	# Check for active perks in the strength column
	for perk in strength_perks:
		if stats["strength"] >= perk.required_stat_level:
			active_perks.append(perk)

	# Check for active perks in the agility column
	for perk in agility_perks:
		if stats["agility"] >= perk.required_stat_level:
			active_perks.append(perk)

func get_perk_effects(target: String) -> Array[float]:
	var all_perk_effects: Array[float] = []

	for perk in active_perks:
		if perk.effect_target == target:
			all_perk_effects.append(perk.get_current_effect())

	return all_perk_effects
