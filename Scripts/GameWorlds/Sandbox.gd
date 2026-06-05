# The GameWorld for the sandbox

extends GameWorld


func command_load_world():
	spawn_player()
	connect_camera()

	world_ready.emit()

func spawn_player():
	player = preload("res://Assets/Player/player.tscn").instantiate()
	player_spawn.add_child(player)

	player_spawned.emit(player)

func connect_camera():
	camera.target = player

func spawn_object(object: PackedScene):
	var new_object = object.instantiate()
	environment.add_child(new_object)
	new_object.position = player.global_position + Vector2.RIGHT * 20
	spawned_objects.append(new_object)
