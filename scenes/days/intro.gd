extends Node2D

@onready var player: Player = $Player
@export var intro_timeline: String = "intro"
@export var interface: Ui
@export_file("*.tscn") var day_1_scene_path: String

func _ready() -> void:
	start_intro_sequence()

func start_intro_sequence() -> void:
	# Disable player control
	player.interacting = true
	await get_tree().create_timer(0.5).timeout
	interface.set_current_day("monday")
	start_dialogue()

func start_dialogue() -> void:
	# Play idle animation when reaching destination
	player.play_idle_animation()
	
	# Connect to dialogue end signal
	Dialogic.signal_event.connect(_on_dialogue_signal)
	Dialogic.timeline_ended.connect(_on_timeline_ended)
	
	# Start the intro dialogue
	var layout: Node = Dialogic.start(intro_timeline)
	layout.register_character("director", player)

func _on_timeline_ended() -> void:
	# Disconnect signals
	Dialogic.signal_event.disconnect(_on_dialogue_signal)
	Dialogic.timeline_ended.disconnect(_on_timeline_ended)

	await get_tree().create_timer(3.0).timeout
	get_tree().change_scene_to_file(day_1_scene_path)

func _on_dialogue_signal(argument: String) -> void:
	pass
