# A GameWorld type parent class, which is a contained scene that is loaded by the GameWorldManager

extends Node
class_name GameWorld

# Universal signals
signal world_ready
signal player_spawned(player)

# Universal onready vars
@onready var player_spawn = $PlayerSpawn
@onready var environment = $Environment
@onready var camera = $Camera2D

# Universal variables
var player 
var spawned_objects: Array[Node]

# Called by the GameWorldManager to initiate loading the world (such as spawning the player appropriately)
func command_load_world():
    pass

# Called by the GameWorldManager whenever there needs to be a forced object spawn, such as from the debug terminal
func spawn_object(object: PackedScene):
    pass