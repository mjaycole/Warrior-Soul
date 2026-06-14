# A GameWorld type parent class, which is a contained scene that is loaded by the GameWorldManager

extends Node
class_name GameWorld

# Universal signals
signal world_ready
signal player_spawned(player)
signal unload_completed
signal new_game_world_requested(new_world: String)

# Universal onready vars
@onready var player_spawn = $PlayerSpawn
@onready var enemy_spawn = $EnemySpawn
@onready var environment = $Environment
@onready var camera = $Camera2D

# Universal variables
var player 
var spawned_objects: Array[Node]
var world_data: GameWorldData

# Called by the GameWorldManager to initiate loading the world (such as spawning the player appropriately)
func command_load_world(old_world: GameWorldData = null):
    listen_for_transition()

# Called by the GameWorldManager to clean up a world before it moves on to the next
func command_unload_world():
    print("Commanded to unload")
    for object in spawned_objects:
        if is_instance_valid(object):
            object.queue_free()
    print("Unload done")
    spawned_objects.clear()
    unload_completed.emit()

# Called by the GameWorldManager whenever there needs to be a forced object spawn, such as from the debug terminal
func spawn_object(object: PackedScene, type: String):
    pass

# Add the listeners to all the transitions inside this game world
func listen_for_transition():
    var transitions = find_children("*", "GameWorldTransition", true, false)
    for transition in transitions:
        transition.transition_game_world_request.connect(handle_game_world_transition_request)

func handle_game_world_transition_request(new_world: String):
    new_game_world_requested.emit(new_world)