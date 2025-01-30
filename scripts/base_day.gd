class_name BaseDay
extends Node2D

@onready var player: Player = $Player

@export var next_scene: PackedScene
@export var interface: Ui

@export var end_day_timeline: String
@export var day: String


var end_sequence_ready := false
var can_trigger_end    := false
var dialogue_cooldown  := false
var cooldown_timer: Timer
var check_timer: Timer


# Virtual method to be overridden by child classes
func _get_completion_conditions() -> bool:
	push_error("_get_completion_conditions must be implemented in child class")
	return false


func _ready() -> void:
	interface.set_current_day(day)
	_setup_timers()
	# Connect to Dialogic signals
	Dialogic.timeline_ended.connect(_on_any_dialogue_ended)


func _setup_timers() -> void:
	# Create and configure cooldown timer
	cooldown_timer = Timer.new()
	cooldown_timer.one_shot = true
	cooldown_timer.wait_time = 3.0
	cooldown_timer.timeout.connect(_on_cooldown_timer_timeout)
	add_child(cooldown_timer)

	# Create and configure check timer
	check_timer = Timer.new()
	check_timer.one_shot = false
	check_timer.wait_time = 1.0
	check_timer.timeout.connect(_check_end_conditions)
	add_child(check_timer)
	check_timer.start()


func _check_end_conditions() -> void:
	if not end_sequence_ready:
		if _get_completion_conditions():
			end_sequence_ready = true
			can_trigger_end = true

	if end_sequence_ready and can_trigger_end and not dialogue_cooldown and not Dialogic.current_timeline:
		start_end_sequence()


func _on_any_dialogue_ended() -> void:
	dialogue_cooldown = true
	cooldown_timer.start()


func _on_cooldown_timer_timeout() -> void:
	dialogue_cooldown = false


func start_end_sequence() -> void:
	check_timer.stop()
	can_trigger_end = false
	end_sequence_ready = false
	player.interacting = true
	start_dialogue()


func start_dialogue() -> void:
	player.play_idle_animation()
	var layout: Node = Dialogic.start(end_day_timeline)
	Dialogic.timeline_ended.connect(_on_timeline_ended, CONNECT_ONE_SHOT)
	layout.register_character("director", player)


func _on_timeline_ended() -> void:
	await get_tree().create_timer(0.5).timeout
	Transition.transition()
	await Transition.on_transition_finished
	get_tree().change_scene_to_packed(next_scene)
