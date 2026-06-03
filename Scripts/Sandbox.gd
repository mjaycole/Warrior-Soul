#Controls the sandbox world

extends Node

@onready var player_spawn = $PlayerSpawn
@onready var camera = $Camera2D

var player

func _ready():
	spawn_player()
	connect_camera()

func spawn_player():
	player = preload("res://Assets/Player/player.tscn").instantiate()
	player_spawn.add_child(player)

func connect_camera():
	camera.target = player
