#Weapon items

extends Item
class_name Weapon

enum WeaponType { MELEE, BOW }

@export var weapon_type: WeaponType = WeaponType.MELEE
@export var attack_time: float = .25
@export var momentum_force: float = 20
