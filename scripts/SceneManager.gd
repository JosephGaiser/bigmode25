class_name SceneManager
extends Node

signal day_started(day_number: int)
signal day_ended(day_number: int)
signal game_completed
signal day_failed(reason: String)

const MAX_DAYS = 5
const DAY_SCENES = {
					 1: preload("res://scenes/days/day_1.tscn"),
					 2: preload("res://scenes/days/day_2.tscn"),
					 3: preload("res://scenes/days/day_3.tscn"),
					 4: preload("res://scenes/days/day_4.tscn"),
					 5: preload("res://scenes/days/day_5.tscn")
				 }

var current_day: int = 1
var day_state: Dictionary = {}
var last_saved_state: Dictionary = {}

# Autoload singleton, runs when game starts
func _ready() -> void:
	initialize_day_state()
	# Connect to Dialogic's save/load signals if needed
	Dialogic.Save.saved.connect(_on_dialogic_saved)
	Dialogic.Save.loaded.connect(_on_dialogic_loaded)

# Initialize persistent state for all days
func initialize_day_state() -> void:
	day_state.clear()
	for day in range(1, MAX_DAYS + 1):
		day_state[day] = {
			"completed": false,
			"choices_made": [],
			"npcs_talked_to": [],
			"failed_attempts": 0
		}

# Start specified day scene
func start_day(day_number: int) -> void:
	if day_number < 1 or day_number > MAX_DAYS:
		push_error("Invalid day number: %d" % day_number)
		return

	current_day = day_number
	var day_scene = DAY_SCENES[current_day].instantiate()

	# Connect to any day-specific signals
	if day_scene.has_signal("day_completed"):
		day_scene.day_completed.connect(_on_day_completed)
	if day_scene.has_signal("day_failed"):
		day_scene.day_failed.connect(_on_day_failed)

	# Replace current scene
	var current_scene = get_tree().current_scene
	get_tree().root.remove_child(current_scene)
	current_scene.queue_free()

	get_tree().root.add_child(day_scene)
	get_tree().current_scene = day_scene

	# Create an autosave at the start of each day
	save_game_state(true)

	day_started.emit(current_day)

# Restart current day
func restart_day() -> void:
	# Increment failed attempts counter
	if day_state.has(current_day):
		day_state[current_day].failed_attempts += 1

	# Load the last saved state for this day
	load_game_state(true)

	# Start the day fresh
	start_day(current_day)

# Handle day failure
func _on_day_failed(reason: String) -> void:
	day_failed.emit(reason)
	restart_day()

# Advance to next day
func advance_day() -> void:
	var next_day = current_day + 1

	if next_day > MAX_DAYS:
		game_completed.emit()
		return

	start_day(next_day)

# Record important choices/events for the current day
func record_choice(choice_id: String) -> void:
	if not day_state.has(current_day):
		return

	if not choice_id in day_state[current_day].choices_made:
		day_state[current_day].choices_made.append(choice_id)

# Record NPC interactions
func record_npc_interaction(npc_id: String) -> void:
	if not day_state.has(current_day):
		return

	if not npc_id in day_state[current_day].npcs_talked_to:
		day_state[current_day].npcs_talked_to.append(npc_id)

# Get all recorded choices for a specific day
func get_day_choices(day_number: int) -> Array:
	if not day_state.has(day_number):
		return []
	return day_state[day_number].choices_made

# Get all NPC interactions for a specific day
func get_day_npc_interactions(day_number: int) -> Array:
	if not day_state.has(day_number):
		return []
	return day_state[day_number].npcs_talked_to

# Check if specific NPC was talked to on a given day
func was_npc_talked_to(npc_id: String, day_number: int) -> bool:
	if not day_state.has(day_number):
		return false
	return npc_id in day_state[day_number].npcs_talked_to

# Get number of failed attempts for current day
func get_failed_attempts() -> int:
	if not day_state.has(current_day):
		return 0
	return day_state[current_day].failed_attempts

# Signal handler for day completion
func _on_day_completed() -> void:
	if not day_state.has(current_day):
		return

	day_state[current_day].completed = true
	day_ended.emit(current_day)
	advance_day()

# Save game state with optional autosave flag
func save_game_state(is_autosave: bool = false) -> void:
	var save_data = {
						"current_day": current_day,
						"day_state": day_state
					}

	# Store last saved state for potential restarts
	last_saved_state = save_data.duplicate(true)

	# Use Dialogic's save system
	Dialogic.Save.save("", is_autosave, Dialogic.Save.ThumbnailMode.NONE)

# Load game state with optional autosave flag
func load_game_state(is_autosave: bool = false) -> void:
	# If loading autosave, use the last_saved_state
	if is_autosave and not last_saved_state.is_empty():
		if last_saved_state.has("current_day"):
			current_day = last_saved_state.current_day
		if last_saved_state.has("day_state"):
			day_state = last_saved_state.day_state.duplicate(true)
	else:
		# Use Dialogic's load system for regular saves
		Dialogic.Save.load()

# Dialogic save callback
func _on_dialogic_saved() -> void:
	# Add any additional save handling here
	pass

# Dialogic load callback
func _on_dialogic_loaded() -> void:
	# Add any additional load handling here
	pass
