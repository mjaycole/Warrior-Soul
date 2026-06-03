#Weapon items

extends Item
class_name Weapon

enum WeaponType { MELEE, BOW }

@export var weapon_type: WeaponType = WeaponType.MELEE
@export var momentum_force: float = 20
@export var damage: float = 10
@export var damage_dealer_node: PackedScene
