class_name PowerDynamicsManager
extends Node

signal game_over(reason: String)
signal update_ui_values()

# Power axes
var morale: float     = 50.0
var profits: float    = 50.0
var reputation: float = 50.0
var authority: float  = 50.0
# Configurable limits
const MIN_VALUE: float           = 0.0
const MAX_VALUE: float           = 100.0
const GAME_OVER_THRESHOLD: float = 10.0

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
			if new_value <= GAME_OVER_THRESHOLD or new_value >= (MAX_VALUE - GAME_OVER_THRESHOLD):
				trigger_game_over(axis)
	update_ui_values.emit()


func trigger_game_over(failed_axis: String) -> void:
	var game_over_reasons: Dictionary = {
											"morale": "Employee morale collapsed",
											"profits": "Company went bankrupt",
											"reputation": "Your reputation is destroyed",
											"authority": "You lost all management control"
										}

	emit_signal("game_over", game_over_reasons[failed_axis])


func get_current_status() -> Dictionary:
	return {
		"morale": morale,
		"profits": profits,
		"reputation": reputation,
		"authority": authority
	}


# Helper method for dialogue interactions
func process_dialogue_choice(choice_effects: Dictionary) -> void:
	adjust_power_axes(choice_effects)
