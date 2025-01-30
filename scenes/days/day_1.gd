class_name Day1
extends Node2D

@onready var player: Player = $Player
@export var end_day_timeline: String = "day_1_end"
@export var interface: Ui
@export var day: String
@export_file("*.tscn") var next_scene_path: String

var end_sequence_ready := false
var can_trigger_end := false
var dialogue_cooldown := false
var cooldown_timer: Timer

func _ready() -> void:
	interface.set_current_day(day)
	# Create and configure cooldown timer
	cooldown_timer = Timer.new()
	cooldown_timer.one_shot = true
	cooldown_timer.wait_time = 3.0  # Adjust this value as needed
	cooldown_timer.timeout.connect(_on_cooldown_timer_timeout)
	add_child(cooldown_timer)
	# Connect to Dialogic signals
	Dialogic.timeline_ended.connect(_on_any_dialogue_ended)

func _process(delta):
	if end_sequence_ready and can_trigger_end and not dialogue_cooldown and not Dialogic.current_timeline:
		start_end_sequence()

	# Check if all dialogues are completed
	if Dialogic.VAR.Rae.day_1 and \
	Dialogic.VAR.Billy.day_1 and \
	Dialogic.VAR.Carl.day_1 and \
	Dialogic.VAR.Chet.day_1 and \
	Dialogic.VAR.Samuel.day_1:
		end_sequence_ready = true
		can_trigger_end = true

func _on_any_dialogue_ended() -> void:
	dialogue_cooldown = true
	cooldown_timer.start()

func _on_cooldown_timer_timeout() -> void:
	dialogue_cooldown = false

func start_end_sequence() -> void:
	# Prevent multiple triggers
	can_trigger_end = false
	# Disable player control
	player.interacting = true
	start_dialogue()
	# Wait for dialogue to complete before resetting flag
	await Dialogic.timeline_ended
	end_sequence_ready = false

func start_dialogue() -> void:
	# Play idle animation when reaching destination
	player.play_idle_animation()

	# Connect to dialogue end signal
	Dialogic.signal_event.connect(_on_dialogue_signal)
	Dialogic.timeline_ended.connect(_on_timeline_ended)

	# Start the intro dialogue
	var layout: Node = Dialogic.start(end_day_timeline)
	layout.register_character("director", player)

func _on_timeline_ended() -> void:
	# Disconnect signals
	Dialogic.signal_event.disconnect(_on_dialogue_signal)
	Dialogic.timeline_ended.disconnect(_on_timeline_ended)

	await get_tree().create_timer(3.0).timeout
	get_tree().change_scene_to_file(next_scene_path)

func _on_dialogue_signal(argument: String) -> void:
	pass
