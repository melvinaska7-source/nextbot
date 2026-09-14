extends Control
## Виртуальный джойстик для движения.
## output.x = влево/вправо (-1..1), output.y = назад/вперёд (-1..1, вверх = +1)

@export var radius: float = 100.0

var output: Vector2 = Vector2.ZERO

var _touch_index: int = -1
var _base_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	_base_position = size / 2.0

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and _touch_index == -1 and get_global_rect().has_point(event.position):
			_touch_index = event.index
			_update_output(event.position)
			get_viewport().set_input_as_handled()
		elif not event.pressed and event.index == _touch_index:
			_touch_index = -1
			output = Vector2.ZERO
			queue_redraw()
	elif event is InputEventScreenDrag and event.index == _touch_index:
		_update_output(event.position)
		get_viewport().set_input_as_handled()

func _update_output(global_touch_pos: Vector2) -> void:
	var local_pos: Vector2 = global_touch_pos - global_position - _base_position
	local_pos = local_pos.limit_length(radius)
	output = Vector2(local_pos.x / radius, -local_pos.y / radius)
	queue_redraw()

func _draw() -> void:
	draw_circle(_base_position, radius, Color(1, 1, 1, 0.15))
	draw_circle(_base_position, radius, Color(1, 1, 1, 0.4), false, 3.0)
	var knob_pos: Vector2 = _base_position + Vector2(output.x, -output.y) * radius
	draw_circle(knob_pos, radius * 0.4, Color(1, 1, 1, 0.5))
