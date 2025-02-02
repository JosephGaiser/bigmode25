class_name Ui
extends Control

@export_group("Progress Bars")
@export var morale_bar: ProgressBar
@export var profits_bar: ProgressBar
@export var reputation_bar: ProgressBar
@export var authorithy_bar: ProgressBar
@export var audio_player: AudioStreamPlayer

@export_group("Days")
@export var monday: Control
@export var tuesday: Control
@export var wednesday: Control
@export var thursday: Control
@export var friday: Control

@export_group("Sound Effects")
@export var slow_change_sound: AudioStream
@export var medium_change_sound: AudioStream
@export var fast_change_sound: AudioStream

@export_group("Timing")
@export var tween_duration: float = 1.0  # Duration of each bar's animation
@export var pause_between_stats: float = 0.5  # Pause between each stat update



# Store previous values to detect changes
var previous_values: Dictionary = {}
const CHANGE_THRESHOLDS = {
									  "slow": 5.0,    # Changes up to 5 points
									  "medium": 15.0, # Changes up to 15 points
									  "fast": 100.0   # Changes above 15 points
								  }

var day_positions: Dictionary = {}
var current_day: Control = null
const DAY_RAISE_AMOUNT = 25  # Pixels to raise the selected day
const DAY_TWEEN_DURATION = 1.0  # Duration of the day change animation

# Define the order of updates
var update_order = ["morale", "profits", "reputation", "authority"]

func _ready():
	# Add AudioStreamPlayer if it doesn't exist
	if !has_node("AudioStreamPlayer"):
		audio_player = AudioStreamPlayer.new()
		audio_player.name = "AudioStreamPlayer"
		add_child(audio_player)

	power_manager.update_ui_values.connect(Callable(self, "_on_update_ui_values"))
	power_manager.game_over.connect(_on_game_over)

	# Initialize UI with starting values
	var initial_status = power_manager.get_current_status()

	# First set the previous values
	for stat_name in update_order:
		if initial_status.has(stat_name):
			previous_values[stat_name] = float(initial_status[stat_name])
			# Instantly set initial bar values without animation
			var bar = get_bar_for_stat(stat_name)
			if bar:
				bar.value = float(initial_status[stat_name])

	for day_node in [monday, tuesday, wednesday, thursday, friday]:
		if day_node:
			day_positions[day_node] = day_node.position

func get_bar_for_stat(stat_name: String) -> ProgressBar:
	match stat_name:
		"morale":
			return morale_bar
		"profits":
			return profits_bar
		"reputation":
			return reputation_bar
		"authority":
			return authorithy_bar
	return null

func _on_game_over(reason: String) -> void:
	return

func get_change_sound(change_amount: float) -> AudioStream:
	var abs_change = abs(change_amount)

	if abs_change <= CHANGE_THRESHOLDS.slow:
		return slow_change_sound
	elif abs_change <= CHANGE_THRESHOLDS.medium:
		return medium_change_sound
	else:
		return fast_change_sound

func update_single_stat(tween: Tween, stat_name: String, new_value: float) -> void:
	var bar = get_bar_for_stat(stat_name)
	if !bar:
		return

	var previous_value = previous_values.get(stat_name, new_value)
	var change = new_value - previous_value

	if change != 0:
		var sound = get_change_sound(change)
		if sound:
			audio_player.stream = sound
			tween.tween_callback(func(): audio_player.play())

		# Animate the bar
		tween.tween_property(
			bar,
			"value",
			new_value,
			tween_duration
		).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

		if sound:
			tween.tween_callback(func(): audio_player.stop())

		# Add pause after the update
		tween.tween_interval(pause_between_stats)

		# Update the previous value
		previous_values[stat_name] = new_value

func update_ui_values() -> void:
	var status: Dictionary = power_manager.get_current_status()
	var tween = create_tween()

	# Update each stat in order
	for stat_name in update_order:
		if status.has(stat_name):
			update_single_stat(tween, stat_name, float(status[stat_name]))

func _on_update_ui_values():
	update_ui_values()

func set_current_day(day_name: String) -> void:
	var day_node: Control = _get_day_node(day_name)
	if !day_node:
		push_error("Invalid day name: " + day_name)
		return

	var tween: Tween = create_tween()
	tween.set_parallel(true)  # Allow multiple properties to animate simultaneously

	# If there was a previously selected day, move it back
	if current_day && current_day != day_node:
		tween.tween_property(
			current_day,
			"position",
			day_positions[current_day],
			DAY_TWEEN_DURATION
		).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

	# Move the new day up
	var target_position = day_positions[day_node] - Vector2(0, DAY_RAISE_AMOUNT)
	tween.tween_property(
		day_node,
		"position",
		target_position,
		DAY_TWEEN_DURATION
	).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN)

	# Update current day reference
	current_day = day_node

func _get_day_node(day_name: String) -> Control:
	match day_name.to_lower():
		"monday":
			return monday
		"tuesday":
			return tuesday
		"wednesday":
			return wednesday
		"thursday":
			return thursday
		"friday":
			return friday
	return null
