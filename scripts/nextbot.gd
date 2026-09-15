extends CharacterBody3D

@export var speed: float = 5.0
@export var catch_distance: float = 1.2
@export var path_update_interval: float = 0.2
@export var radar_distance: float = 14.0

var player: Node3D = null
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _path_timer: float = 0.0
var _caught: bool = false
var _radar_active: bool = false
var _spawn_position: Vector3

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var radar_sfx: AudioStreamPlayer3D = $RadarSfx

func _ready() -> void:
	add_to_group("enemies")
	player = get_tree().get_first_node_in_group("player")
	nav_agent.path_desired_distance = 0.5
	nav_agent.target_desired_distance = 0.6
	_spawn_position = global_position

func _physics_process(delta: float) -> void:
	if player == null or _caught:
		return

	if global_position.y < -10.0:
		reset(_spawn_position)
		return

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	_path_timer -= delta
	if _path_timer <= 0.0:
		nav_agent.target_position = player.global_position
		_path_timer = path_update_interval

	if not nav_agent.is_navigation_finished():
		var next_point: Vector3 = nav_agent.get_next_path_position()
		var to_next: Vector3 = next_point - global_position
		to_next.y = 0.0
		if to_next.length() > 0.05:
			to_next = to_next.normalized()
			velocity.x = to_next.x * speed
			velocity.z = to_next.z * speed
			look_at(global_position + to_next, Vector3.UP)
		else:
			velocity.x = 0.0
			velocity.z = 0.0
	else:
		velocity.x = 0.0
		velocity.z = 0.0

	move_and_slide()

	var dist: float = global_position.distance_to(player.global_position)

	if dist <= radar_distance and not _radar_active:
		_radar_active = true
		radar_sfx.play()
	elif dist > radar_distance + 3.0:
		_radar_active = false

	if dist <= catch_distance:
		_caught = true
		velocity = Vector3.ZERO
		ChaseManager.player_caught.emit()

func reset(spawn_position: Vector3) -> void:
	global_position = spawn_position
	velocity = Vector3.ZERO
	_caught = false
