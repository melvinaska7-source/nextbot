extends Control
## Простая touch-кнопка (прямоугольная зона под собой).
## Работает независимо от джойстика/свайпа - каждый палец отслеживается отдельно.

signal button_pressed
signal button_released

var _touch_index: int = -1

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and _touch_index == -1 and get_global_rect().has_point(event.position):
			_touch_index = event.index
			button_pressed.emit()
			get_viewport().set_input_as_handled()
		elif not event.pressed and event.index == _touch_index:
			_touch_index = -1
			button_released.emit()
			get_viewport().set_input_as_handled()
