class_name EnemyUI
extends Control

@export_group("Progress Bars")
@export var morale_bar: ProgressBar
@export var profits_bar: ProgressBar
@export var reputation_bar: ProgressBar
@export var authority_bar: ProgressBar
@export var audio_player: AudioStreamPlayer
@export_group("Sound Effects")
@export var damage_sound: AudioStream
@export var large_damage_sound: AudioStream
@export_group("Timing")
@export var tween_duration: float = 0.5
@export var pause_between_updates: float = 0.2

# Store previous values to detect changes
var previous_values: Dictionary = {}
const LARGE_DAMAGE_THRESHOLD    = 15.0
# Define update order
var update_order = ["morale", "profits", "reputation", "authority"]


func _ready() -> void:
	if !audio_player:
		audio_player = AudioStreamPlayer.new()
		add_child(audio_player)

	# Connect to enemy power manager
	enemy_power_manager.update_enemy_ui.connect(Callable(self, "_on_update_enemy_ui"))
	enemy_power_manager.enemy_defeated.connect(_on_enemy_defeated)

	# Initialize UI with starting values
	var initial_status = enemy_power_manager.get_current_status()

	for stat_name in update_order:
		if initial_status.has(stat_name):
			previous_values[stat_name] = float(initial_status[stat_name])
			var bar = get_bar_for_stat(stat_name)
			if bar:
				bar.value = float(initial_status[stat_name])


func get_bar_for_stat(stat_name: String) -> ProgressBar:
	match stat_name:
		"morale":
			return morale_bar
		"profits":
			return profits_bar
		"reputation":
			return reputation_bar
		"authority":
			return authority_bar
	return null


func get_damage_sound(change_amount: float) -> AudioStream:
	return large_damage_sound if abs(change_amount) >= LARGE_DAMAGE_THRESHOLD else damage_sound


func update_single_stat(tween: Tween, stat_name: String, new_value: float) -> void:
	var bar = get_bar_for_stat(stat_name)
	if !bar:
		return

	var previous_value = previous_values.get(stat_name, new_value)
	var change         = new_value - previous_value

	if change != 0:
		var sound = get_damage_sound(change)
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

		# Add pause after update
		tween.tween_interval(pause_between_updates)

		# Update previous value
		previous_values[stat_name] = new_value


func update_ui_values() -> void:
	var status = enemy_power_manager.get_current_status()
	var tween  = create_tween()

	# Update each stat in order
	for stat_name in update_order:
		if status.has(stat_name):
			update_single_stat(tween, stat_name, float(status[stat_name]))


func _on_update_enemy_ui() -> void:
	update_ui_values()


func _on_enemy_defeated(_reason: String) -> void:
	self.visible = false
