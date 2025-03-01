class_name PowerDynamicsManager
extends Node

signal game_over(reason: String)
signal update_ui_values()

const GAME_OVER = preload("res://scenes/days/game_over.tscn")
const GAME_WIN = preload("res://scenes/days/win.tscn")
var current_day = "day_1"

# Power axes
var morale: float     = 50.0
var profits: float    = 50.0
var reputation: float = 50.0
var authority: float  = 50.0
# Configurable limits
const MIN_VALUE: float           = 0.0
const MAX_VALUE: float           = 100.0
const GAME_OVER_THRESHOLD: float = 0.0

var snapshot: Dictionary = {}

func gain_moral(amount := 10.0) -> void:
	adjust_power_axes({"morale": amount})


func lose_moral(amount := 10.0) -> void:
	adjust_power_axes({"morale": -amount})


func gain_profits(amount := 10.0) -> void:
	adjust_power_axes({"profits": amount})


func lose_profits(amount := 10.0) -> void:
	adjust_power_axes({"profits": -amount})


func gain_reputation(amount := 10.0) -> void:
	adjust_power_axes({"reputation": amount})


func lose_reputation(amount := 10.0) -> void:
	adjust_power_axes({"reputation": -amount})


func gain_authority(amount := 10.0) -> void:
	adjust_power_axes({"authority": amount})


func lose_authority(amount := 10.0) -> void:
	adjust_power_axes({"authority": -amount})


func adjust_power_axes(changes: Dictionary) -> void:
	# Safely modify each axis
	for axis in ["morale", "profits", "reputation", "authority"]:
		if axis in changes:
			var current_value = get(axis)
			var new_value     = clamp(
									current_value + changes[axis],
									MIN_VALUE,
									MAX_VALUE
								)
			set(axis, new_value)

			# Check for game over conditions
			if new_value <= GAME_OVER_THRESHOLD:
				trigger_game_over(axis)
	update_ui_values.emit()


func snapshot_axes() -> void:
	# Save the current state of the power axes
	snapshot = {
		"morale": morale,
		"profits": profits,
		"reputation": reputation,
		"authority": authority,
		"day": current_day
	}

func trigger_game_over(failed_axis: String) -> void:
	var game_over_reasons: Dictionary = {
											"morale": "Employee morale collapsed",
											"profits": "Company went bankrupt",
											"reputation": "Your reputation is destroyed",
											"authority": "You lost all management control"
										}

	emit_signal("game_over", game_over_reasons[failed_axis])
	await get_tree().create_timer(1.0).timeout
	Dialogic.end_timeline()
	load_scene(GAME_OVER)

func win():
	await get_tree().create_timer(1.0).timeout
	Dialogic.end_timeline()
	load_scene(GAME_WIN)

func get_current_day() -> String:
	return self.current_day
	
func set_current_day(day: String) -> void:
	self.current_day = day

func reset() -> void:
	if snapshot:
		morale     = snapshot["morale"]
		profits    = snapshot["profits"]
		reputation = snapshot["reputation"]
		authority  = snapshot["authority"]
		current_day = snapshot["day"]
	else:
		# Reset to default values
		morale     = 50.0
		profits    = 50.0
		reputation = 50.0
		authority  = 50.0

	# Reset the UI
	update_ui_values.emit()

func get_current_status() -> Dictionary:
	return {
		"morale": morale,
		"profits": profits,
		"reputation": reputation,
		"authority": authority
	}

func load_scene(scene: PackedScene) -> void:
	Transition.transition()
	Dialogic.end_timeline()
	await Transition.on_transition_finished
	get_tree().change_scene_to_packed(scene)

# Helper method for dialogue interactions
func process_dialogue_choice(choice_effects: Dictionary) -> void:
	adjust_power_axes(choice_effects)
