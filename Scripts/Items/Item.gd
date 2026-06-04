extends Resource
class_name Item

enum ItemType { WEAPON }

#Base item data
@export var id: String
@export var item_name: String
@export var item_type: ItemType = ItemType.WEAPON
@export var description: String
@export var icon: Texture2D
@export var weight: float
@export var value: int

#Item use data
@export var item_behavior: PackedScene
@export var use_time: float
@export var use_move_speed: float
