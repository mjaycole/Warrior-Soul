#The main resources that references all the other player data resources

extends Resource
class_name PlayerData

@export var inventory: PlayerInventory
@export var stats: PlayerStat

func initialize():
	if not inventory:
		inventory = PlayerInventory.new()
	if not stats:
		stats = PlayerStat.new()
