extends Node2D

@export var sounds: Array[AudioStream] = []
@export var min_interval: float = 3.0 # Minimum time between sounds
@export var max_interval: float = 7.0  # Maximum time between sounds
@export var volume_db: float = -10.0    # Default volume
@export var random_pitch_variation: float = 0.1  # Pitch variation for variety
@export var audio_max_distance: float = 100.0  # Distance at which sound fades to 0

var _audio_player: AudioStreamPlayer2D
var _timer: Timer
var _rng: RandomNumberGenerator

func _ready() -> void:
	# Initialize RNG
	_rng = RandomNumberGenerator.new()
	_rng.randomize()
	
	# Set up audio player
	_audio_player = AudioStreamPlayer2D.new()
	add_child(_audio_player)
	_audio_player.max_distance = audio_max_distance
	_audio_player.volume_db = volume_db
	
	# Set up timer for random intervals
	_timer = Timer.new()
	add_child(_timer)
	_timer.one_shot = true
	_timer.timeout.connect(_on_timer_timeout)
	
	# Start the cycle if we have sounds
	if not sounds.is_empty():
		_schedule_next_sound()

func _schedule_next_sound() -> void:
	var wait_time = _rng.randf_range(min_interval, max_interval)
	_timer.start(wait_time)

func _on_timer_timeout() -> void:
	play_random_sound()
	_schedule_next_sound()

func play_random_sound() -> void:
	if sounds.is_empty():
		push_warning("Ambient Audio Node: No sounds assigned!")
		return
	
	# Select random sound
	var sound_index = _rng.randi() % sounds.size()
	_audio_player.stream = sounds[sound_index]
	
	# Apply random pitch variation
	_audio_player.pitch_scale = 1.0 + _rng.randf_range(-random_pitch_variation, random_pitch_variation)
	
	_audio_player.play()

# Optional method to manually stop all sounds
func stop() -> void:
	_timer.stop()
	_audio_player.stop()

# Optional method to manually start the ambient sound cycle
func start() -> void:
	if not _timer.is_stopped():
		return
	_schedule_next_sound()
