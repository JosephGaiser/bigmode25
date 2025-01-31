class_name GameOverScreen
extends Node

@export_group("Scenes")
@export var title_scene: PackedScene
@export var intro_scene: PackedScene
@export var day_1_scene: PackedScene
@export var day_2_scene: PackedScene
@export var day_3_scene: PackedScene
@export var day_4_scene: PackedScene
@export var day_5_scene: PackedScene
@export var retry_button: Button
@export var main_menu_button: Button


func _ready() -> void:
	retry_button.pressed.connect(_on_retry_button_pressed)
	main_menu_button.pressed.connect(_on_menu_button_pressed)

func _on_retry_button_pressed() -> void:
	power_manager.reset()
	match power_manager.get_current_day().to_lower():
		"monday":
			load_scene(day_1_scene)
		"tuesday":
			load_scene(day_2_scene)
		"wednesday":
			load_scene(day_3_scene)
		"thursday":
			load_scene(day_4_scene)
		"friday":
			load_scene(day_5_scene)

func _on_menu_button_pressed() -> void: load_scene(title_scene)

func load_scene(scene: PackedScene) -> void:
	Transition.transition()
	await Transition.on_transition_finished
	get_tree().change_scene_to_packed(scene)
