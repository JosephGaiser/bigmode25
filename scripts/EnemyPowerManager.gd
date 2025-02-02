class_name EnemyPowerManager
extends Node

signal enemy_defeated(reason: String)
signal update_enemy_ui()
signal show_enemy_ui()

# Power axes
var morale: float     = 50.0
var profits: float    = 50.0
var reputation: float = 50.0
var authority: float  = 50.0
# Configurable limits
const MIN_VALUE: float        = 0.0
const MAX_VALUE: float        = 100.0
const DEFEAT_THRESHOLD: float = 0.0

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

			# Check for defeat conditions
			if new_value <= DEFEAT_THRESHOLD:
				trigger_defeat(axis)

	update_enemy_ui.emit()

func start():
	show_enemy_ui.emit()

func trigger_defeat(failed_axis: String) -> void:
	var defeat_reasons: Dictionary = {
							 "morale": "Enemy morale collapsed",
							 "profits": "Enemy resources depleted",
							 "reputation": "Enemy reputation destroyed",
							 "authority": "Enemy lost control"
						 }

	enemy_defeated.emit(defeat_reasons[failed_axis])
	Dialogic.VAR.Combat.enemy_defeated = true


func get_current_status() -> Dictionary:
	return {
		"morale": morale,
		"profits": profits,
		"reputation": reputation,
		"authority": authority
	}


func reset_to_default() -> void:
	morale = 50.0
	profits = 50.0
	reputation = 50.0
	authority = 50.0
	update_enemy_ui.emit()


# Helper methods for easy value adjustment
func damage_morale(amount := 10.0) -> void:
	adjust_power_axes({"morale": -amount})


func damage_profits(amount := 10.0) -> void:
	adjust_power_axes({"profits": -amount})


func damage_reputation(amount := 10.0) -> void:
	adjust_power_axes({"reputation": -amount})


func damage_authority(amount := 10.0) -> void:
	adjust_power_axes({"authority": -amount})
