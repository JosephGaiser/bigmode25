class_name BaseNPC
extends Node2D

@export var current_timeline: String = "rae_day_1"
@export var wander_enabled: bool = true
@export_group("movement")
@export var tile_size: int = 16
@export var speed: float = 0.4

@export_range(0.5, 10.0) var base_move_interval: float = 3.0

@export_range(0.0, 5.0) var move_interval_variance: float = 1.0
@export var max_tiles_per_move: int = 2

@export_range(0.0, 5.0) var initial_delay: float = 0.0  # Set in editor for manual control
@export var random_initial_delay: bool = true  # Whether to randomize initial delay

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer
@onready var ray_cast: RayCast2D = $RayCast2D

var moving: bool               = false
var directions: Array[Vector2] = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]


func _ready():
	setup_initial_state()
	setup_movement_timer()


func setup_initial_state():
	animated_sprite_2d.play("idle_down")

	# Apply initial delay before starting movement
	if random_initial_delay:
		initial_delay = randf_range(0.0, base_move_interval)

	if initial_delay > 0:
		await get_tree().create_timer(initial_delay).timeout

	start_movement()


func setup_movement_timer():
	timer.one_shot = false
	timer.timeout.connect(attempt_random_move)


func start_movement() -> void:
	if !wander_enabled:
		return

	randomize_move_interval()
	timer.start()


func randomize_move_interval():
	var min_interval: float = max(0.5, base_move_interval - move_interval_variance)
	var max_interval: float = base_move_interval + move_interval_variance
	timer.wait_time = randf_range(min_interval, max_interval)


func attempt_random_move() -> void:
	if moving or !wander_enabled:
		return

	# Add chance to skip movement
	if randf() < 0.3: # 30% chance to stay idle
		randomize_move_interval()
		return

	var random_direction   = directions.pick_random()
	var tiles_to_move: int = randi_range(1, max_tiles_per_move)

	ray_cast.target_position = random_direction * (tile_size * tiles_to_move)
	ray_cast.force_raycast_update()

	if !ray_cast.is_colliding():
		move(random_direction, tiles_to_move)
	else:
		on_movement_blocked()

	# Randomize next movement interval
	randomize_move_interval()


func move(direction: Vector2, tiles: int) -> void:
	moving = true
	update_animation(direction)

	var tween: Tween        = create_tween()
	var target_pos: Vector2 = position + direction * (tile_size * tiles)

	# Add slight random variation to movement speed
	var speed_variation: float = randf_range(0.9, 1.1)
	var move_duration: float   = speed * tiles * speed_variation

	tween.tween_property(self, "position", target_pos, move_duration)
	tween.tween_callback(stop_moving)


func stop_moving() -> void:
	animated_sprite_2d.play("idle_down")
	moving = false

	# Add random pause after movement
	if randf() < 0.4: # 40% chance for extra pause
		timer.stop()
		await get_tree().create_timer(randf_range(0.5, 1.5)).timeout
		if wander_enabled:
			timer.start()


func update_animation(direction: Vector2) -> void:
	var anim_name: String = ""
	match direction:
		Vector2.UP:
			anim_name = "walk_up"
		Vector2.DOWN:
			anim_name = "walk_down"
		Vector2.LEFT:
			anim_name = "walk_left"
		Vector2.RIGHT:
			anim_name = "walk_right"

	animated_sprite_2d.play(anim_name)


func toggle_wandering(enable: bool):
	wander_enabled = enable
	if !enable:
		animated_sprite_2d.play("idle_down")
		timer.stop()
	else:
		start_movement()


func _on_dialogic_signal(arg: String):
	# Placeholder for NPC behavior
	pass


func on_movement_blocked():
	# Placeholder for specific NPC behavior when movement is blocked
	pass


func interact(player: Player):
	# Placeholder for interaction logic
	pass
