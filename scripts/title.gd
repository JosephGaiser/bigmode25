class_name TitleScreen
extends Control


@export_file("*.tscn") var intro_scene_path: String

@export var start_button: Button
@export var title_label: Label
@export var transition_animation: AnimationPlayer

func _ready() -> void:
	# Connect button signal
	start_button.pressed.connect(_on_start_button_pressed)


func _on_start_button_pressed() -> void:
	# Play transition animation if we have one
	if transition_animation and transition_animation.has_animation("fade_out"):
		transition_animation.play("fade_out")
		await transition_animation.animation_finished

	# Change to the intro scene
	get_tree().change_scene_to_file(intro_scene_path)
