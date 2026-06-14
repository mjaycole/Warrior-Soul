# This handles storing the player's currently perk selections. Each stat has a perk for the base and for each tier

extends Resource
class_name PlayerPerks

# Signals
signal player_perks_changed

@export var active_perks: Array[Perk]

@export var all_perk_columns: Dictionary = {}
@export var strength_perks: Array[Perk]
@export var precision_perks: Array[Perk]
@export var endurance_perks: Array[Perk]
@export var agility_perks: Array[Perk]
@export var resilience_perks: Array[Perk]
@export var instinct_perks: Array[Perk]
@export var luck_perks: Array[Perk]


func _build_perk_columns():
	all_perk_columns = {
		"strength": strength_perks,
		"precision": precision_perks,
		"endurance": endurance_perks,
		"agility": agility_perks,
		"resilience": resilience_perks,
		"instinct": instinct_perks,
		"luck": luck_perks
	}

func update_active_perks(stats: Dictionary):
	_build_perk_columns()
	
	active_perks.clear()

	# Check for active perks in the strength column
	for stat_key in all_perk_columns:
		if not stats.has(stat_key):
			continue

		for perk in all_perk_columns[stat_key]:
			if stats[stat_key] >= perk.required_stat_level:
				active_perks.append(perk)


func get_perk_effects(target: String) -> Array[float]:
	var all_perk_effects: Array[float] = []

	for perk in active_perks:
		if perk.effect_target == target:
			all_perk_effects.append(perk.get_current_effect())

	return all_perk_effects
