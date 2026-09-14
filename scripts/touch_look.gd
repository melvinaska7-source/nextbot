extends Control
## Зона свайпа для поворота камеры (правая часть экрана).

var _delta: Vector2 = Vector2.ZERO
var _touch_index: int = -1

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and _touch_index == -1 and get_global_rect().has_point(event.position):
			_touch_index = event.index
			get_viewport().set_input_as_handled()
		elif not event.pressed and event.index == _touch_index:
			_touch_index = -1
	elif event is InputEventScreenDrag and event.index == _touch_index:
		_delta += event.relative
		get_viewport().set_input_as_handled()

func consume_delta() -> Vector2:
	var d: Vector2 = _delta
	_delta = Vector2.ZERO
	return d
