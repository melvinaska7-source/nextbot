extends Node3D

@onready var nav_region: NavigationRegion3D = $NavigationRegion3D
@onready var player: CharacterBody3D = $NavigationRegion3D/Player
@onready var nextbot: CharacterBody3D = $NavigationRegion3D/Nextbot
@onready var game_over_panel: Control = $UI/GameOverPanel

var player_spawn: Vector3
var nextbot_spawn: Vector3

func _ready() -> void:
	# Запекаем навигацию во время выполнения по геометрии пола/стен.
	nav_region.bake_navigation_mesh()

	player_spawn = player.global_position
	nextbot_spawn = nextbot.global_position

	game_over_panel.visible = false
	ChaseManager.player_caught.connect(_on_player_caught)

func _on_player_caught() -> void:
	get_tree().paused = true
	game_over_panel.visible = true

func _on_restart_pressed() -> void:
	get_tree().paused = false
	game_over_panel.visible = false
	player.global_position = player_spawn
	player.velocity = Vector3.ZERO
	nextbot.reset(nextbot_spawn)
