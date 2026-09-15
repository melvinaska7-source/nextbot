extends Control

@onready var about_panel: Control = $AboutPanel
@onready var settings_panel: Control = $SettingsPanel
@onready var volume_slider: HSlider = $SettingsPanel/VolumeSlider

func _ready() -> void:
	about_panel.visible = false
	settings_panel.visible = false
	var bus_idx: int = AudioServer.get_bus_index("Master")
	volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(bus_idx))

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_settings_pressed() -> void:
	settings_panel.visible = not settings_panel.visible
	about_panel.visible = false

func _on_about_pressed() -> void:
	about_panel.visible = not about_panel.visible
	settings_panel.visible = false

func _on_volume_changed(value: float) -> void:
	var bus_idx: int = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))

func _on_close_about_pressed() -> void:
	about_panel.visible = false

func _on_close_settings_pressed() -> void:
	settings_panel.visible = false
