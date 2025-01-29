extends Node2D

@onready var player: Player = $Player
@export var intro_position: Node2D
@export var intro_timeline: String = "intro"

func _ready() -> void:
	start_intro_sequence()

func start_intro_sequence() -> void:
	# Disable player control
	player.interacting = true
	
	# Create a tween for smooth movement
	var tween = create_tween()
	
	# Calculate movement duration based on distance
	var distance = player.position.distance_to(intro_position.position)
	var duration = distance * player.speed  # Use player's base speed for consistency
	
	# Update player animation
	var direction = (intro_position.position - player.position).normalized()
	update_player_animation(direction)
	
	# Move player to position
	tween.tween_property(player, "position", intro_position.position, duration)
	tween.tween_callback(start_dialogue)

func update_player_animation(direction: Vector2) -> void:
	# Determine which walking animation to play based on movement direction
	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			player.animated_sprite_2d.play("walk_right")
		else:
			player.animated_sprite_2d.play("walk_left")
	else:
		if direction.y > 0:
			player.animated_sprite_2d.play("walk_down")
		else:
			player.animated_sprite_2d.play("walk_up")

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
	
	# Re-enable player control
	player.can_move = true

func _on_dialogue_signal(argument: String) -> void:
	# Handle any special dialogue signals here
	# For example: if argument == "show_npc": show_specific_npc()
	pass
