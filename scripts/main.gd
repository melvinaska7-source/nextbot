extends Node3D

@onready var nav_region: NavigationRegion3D = $NavigationRegion3D
@onready var player: CharacterBody3D = $NavigationRegion3D/Player
@onready var game_over_panel: Control = $UI/GameOverPanel
@onready var lose_sfx: AudioStreamPlayer = $LoseSfx

var teachers: Array[CharacterBody3D] = []
var teacher_spawns: Array[Vector3] = []
var player_spawn: Vector3

func _ready() -> void:
	# Запекаем навигацию во время выполнения по геометрии пола/стен.
	nav_region.bake_navigation_mesh()

	for child in nav_region.get_children():
		if child.is_in_group("enemies"):
			teachers.append(child)
			teacher_spawns.append(child.global_position)

	player_spawn = player.global_position

	game_over_panel.visible = false
	ChaseManager.player_caught.connect(_on_player_caught)

func _on_player_caught() -> void:
	lose_sfx.play()
	get_tree().paused = true
	game_over_panel.visible = true

func _on_restart_pressed() -> void:
	get_tree().paused = false
	game_over_panel.visible = false
	player.global_position = player_spawn
	player.velocity = Vector3.ZERO
	for i in teachers.size():
		teachers[i].reset(teacher_spawns[i])

func _on_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
