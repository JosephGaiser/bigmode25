class_name TitleScreen
extends Control

@export_group("Scenes")
@export var intro_scene: PackedScene
@export var day_1_scene: PackedScene
@export var day_2_scene: PackedScene
@export var day_3_scene: PackedScene
@export var day_4_scene: PackedScene
@export var day_5_scene: PackedScene
@export var start_button: Button
@export var skip_button: Button
@export var title_label: Label
@export var main_menu: VBoxContainer
@export var days_menu: VBoxContainer
@export var day_1: Button
@export var day_2: Button
@export var day_3: Button
@export var day_4: Button
@export var day_5: Button
@export var skip_back: Button


func _ready() -> void:
	main_menu.visible = true
	days_menu.visible = false
	# Connect button signal
	start_button.pressed.connect(_on_start_button_pressed)
	skip_button.pressed.connect(_on_skip_button_pressed)
	day_1.pressed.connect(_on_day_1_pressed)
	day_2.pressed.connect(_on_day_2_pressed)
	day_3.pressed.connect(_on_day_3_pressed)
	day_4.pressed.connect(_on_day_4_pressed)
	day_5.pressed.connect(_on_day_5_pressed)
	skip_back.pressed.connect(_on_skip_back_button_pressed)


func _on_start_button_pressed() -> void: load_scene(intro_scene)

func toggle_skip() -> void:
	main_menu.visible = !main_menu.visible
	days_menu.visible = !days_menu.visible

func _on_skip_button_pressed() -> void:
	toggle_skip()

func _on_skip_back_button_pressed() -> void:
	toggle_skip()

func load_scene(scene: PackedScene) -> void:
	Transition.transition()
	await Transition.on_transition_finished
	get_tree().change_scene_to_packed(scene)


func _on_day_1_pressed() -> void: load_scene(day_1_scene)
func _on_day_2_pressed() -> void: load_scene(day_2_scene)
func _on_day_3_pressed() -> void: load_scene(day_3_scene)
func _on_day_4_pressed() -> void: load_scene(day_4_scene)
func _on_day_5_pressed() -> void: load_scene(day_5_scene)
