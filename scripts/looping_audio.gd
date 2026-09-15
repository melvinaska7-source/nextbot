extends AudioStreamPlayer
## Зацикливает воспроизведение (mp3/ogg сами по себе не всегда лупятся).

func _ready() -> void:
	finished.connect(_on_finished)

func _on_finished() -> void:
	play()
