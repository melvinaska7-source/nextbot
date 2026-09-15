extends CharacterBody3D

# Скорость шага = скорость трудички, спринт = скорость Тишкова.
@export var walk_speed: float = 4.0
@export var sprint_speed: float = 6.5
@export var jump_velocity: float = 4.5
@export var look_sensitivity: float = 0.005
@export var min_pitch_deg: float = -70.0
@export var max_pitch_deg: float = 70.0

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var is_sprinting: bool = false
var _last_safe_position: Vector3

@onready var camera: Camera3D = $Camera3D
@onready var joystick: Control = get_node("/root/Main/UI/Joystick")
@onready var touch_look: Control = get_node("/root/Main/UI/TouchLook")

func _ready() -> void:
	add_to_group("player")
	_last_safe_position = global_position

func _physics_process(delta: float) -> void:
	if is_on_floor():
		_last_safe_position = global_position
	elif global_position.y < -10.0:
		# страховка: если где-то провалились сквозь геометрию - вернуть на последнюю точку на полу
		global_position = _last_safe_position
		velocity = Vector3.ZERO

	if not is_on_floor():
		velocity.y -= gravity * delta

	# Поворот от свайпа: yaw крутит тело, pitch крутит только камеру.
	var look_delta: Vector2 = touch_look.consume_delta()
	rotate_y(-look_delta.x * look_sensitivity)
	var new_pitch: float = camera.rotation.x - look_delta.y * look_sensitivity
	camera.rotation.x = clamp(new_pitch, deg_to_rad(min_pitch_deg), deg_to_rad(max_pitch_deg))

	# Движение от джойстика.
	var input_dir: Vector2 = joystick.output
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0.0, -input_dir.y))
	direction.y = 0.0
	if direction.length() > 0.01:
		direction = direction.normalized()

	var speed: float = sprint_speed if is_sprinting else walk_speed

	if direction.length() > 0.01:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed)
		velocity.z = move_toward(velocity.z, 0.0, speed)

	move_and_slide()

func jump() -> void:
	if is_on_floor():
		velocity.y = jump_velocity

func set_sprint(value: bool) -> void:
	is_sprinting = value
