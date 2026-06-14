# The GameWorld for the sandbox

extends GameWorld



func command_load_world(old_world: GameWorldData = null):
	super.command_load_world(old_world)

	spawn_player()
	init_enemies()
	connect_camera()

	world_ready.emit()

func spawn_player():
	player = load("res://Assets/Player/player.tscn").instantiate()
	player_spawn.add_child(player)

	player_spawned.emit(player)

func init_enemies():
	for enemy in enemy_spawn.get_children():
		enemy.initialize()

func connect_camera():
	camera.target = player

func spawn_object(object: PackedScene, type: String):
	var new_object = object.instantiate()
	
	environment.add_child(new_object)

	if type == "enemy":
		enemy_spawn.add_child(new_object)

	new_object.position = player.global_position + Vector2.RIGHT * 20
	spawned_objects.append(new_object)

	if type == "enemy":
		new_object.initialize()
