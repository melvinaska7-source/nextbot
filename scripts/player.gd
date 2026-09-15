extends CharacterBody3D

# Скорость шага = скорость трудички, спринт = скорость Тишкова.
@export var walk_speed: float = 4.0
@export var sprint_speed: float = 6.5
@export var jump_velocity: float = 4.5
@export var look_sensitivity: float = 0.005
@export var min_pitch_deg: float = -70.0
@export var max_pitch_deg: float = 70.0

# Прыжковое ускорение: каждый прыжок в движении добавляет временный буст
# к скорости (как банихоп). Если не прыгать снова вовремя - буст сгорает.
@export var hop_bonus_step: float = 0.35
@export var max_hop_bonus: float = 1.5
@export var hop_bonus_grace_time: float = 0.35

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var is_sprinting: bool = false
var _last_safe_position: Vector3
var hop_speed_multiplier: float = 1.0
var _time_since_landed: float = 0.0

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

	var speed: float = (sprint_speed if is_sprinting else walk_speed) * hop_speed_multiplier

	if is_on_floor():
		_time_since_landed += delta
		if _time_since_landed > hop_bonus_grace_time:
			hop_speed_multiplier = 1.0

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
		hop_speed_multiplier = min(hop_speed_multiplier + hop_bonus_step, 1.0 + max_hop_bonus)
		_time_since_landed = 0.0

func set_sprint(value: bool) -> void:
	is_sprinting = value
