class_name FootstepManager
extends Node

# Movement and timing settings
@export var step_interval: float = 0.3  # Time between footsteps
@export var movement_threshold: float = 0.1  # Minimum movement speed to play steps

# Sound variation settings
@export var randomize_pitch: bool = true
@export var pitch_range: Vector2 = Vector2(0.9, 1.1)

# Audio player settings
@export_group("Audio Settings")
@export var volume_db: float = 0.0
@export var max_distance: float = 200
@export var attenuation: float = 1.0  # Linear attenuation
@export var bus_name: String = "Master"
@export var area_mask: int = 1

# Preload the footstep sounds
@export_group("Sound Assets")
@export var footstep_sounds: Array[AudioStream] = []

# Node references
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var step_timer: Timer = $StepTimer
@onready var parent = get_parent()

var current_sound_index: int = 0
var last_position: Vector2 = Vector2.ZERO
var can_play: bool = true

func _ready() -> void:
	# Create the step timer
	if !has_node("StepTimer"):
		step_timer = Timer.new()
		step_timer.name = "StepTimer"
		add_child(step_timer)

	step_timer.wait_time = step_interval
	step_timer.one_shot = true
	step_timer.timeout.connect(_on_step_timer_timeout)

	# Create and configure audio player
	if !has_node("AudioStreamPlayer2D"):
		audio_player = AudioStreamPlayer2D.new()
		audio_player.name = "AudioStreamPlayer2D"
		add_child(audio_player)

	# Configure audio player settings
	configure_audio_player()

	last_position = parent.position

func configure_audio_player() -> void:
	audio_player.volume_db = volume_db
	audio_player.max_distance = max_distance
	audio_player.attenuation = attenuation
	audio_player.bus = bus_name
	audio_player.area_mask = area_mask

func _physics_process(_delta: float) -> void:
	if !parent:
		return

	var movement = (parent.position - last_position).length()

	if movement > movement_threshold and can_play:
		play_footstep()
		can_play = false
		step_timer.start()

	last_position = parent.position

func play_footstep() -> void:
	if footstep_sounds.is_empty():
		push_warning("No footstep sounds assigned to FootstepManager!")
		return

	# Get the next sound in rotation
	var sound = footstep_sounds[current_sound_index]

	# Set the sound on our single audio player
	audio_player.stream = sound

	# Randomize pitch if enabled
	if randomize_pitch:
		audio_player.pitch_scale = randf_range(pitch_range.x, pitch_range.y)

	audio_player.play()

	# Update the sound index for next footstep
	current_sound_index = (current_sound_index + 1) % footstep_sounds.size()

func _on_step_timer_timeout() -> void:
	can_play = true

# Optional: Public methods to control the footstep system
func start_footsteps() -> void:
	set_physics_process(true)
	can_play = true

func stop_footsteps() -> void:
	set_physics_process(false)
	can_play = false
	step_timer.stop()

# Runtime audio configuration methods
func set_volume(db: float) -> void:
	volume_db = db
	audio_player.volume_db = db

func set_max_distance(distance: float) -> void:
	max_distance = distance
	audio_player.max_distance = distance

func set_attenuation(value: float) -> void:
	attenuation = value
	audio_player.attenuation = value
