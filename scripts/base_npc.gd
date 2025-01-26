class_name BaseNPC
extends Node2D

@export var tile_size: int = 16
@export var speed: float = 0.4
@export var move_interval: float = 3.0
@export var max_tiles_per_move: int = 2

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer
@onready var ray_cast: RayCast2D = $RayCast2D

var moving: bool = false
var wander_enabled: bool = true
var directions: Array[Vector2] = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]

func _ready():
	setup_initial_state()
	timer.wait_time = move_interval
	timer.timeout.connect(attempt_random_move)
	timer.start()
	
	Dialogic.Styles.load_style("custom_bubble")

func setup_initial_state():
	animated_sprite_2d.play("idle_down")

func attempt_random_move() -> void:
	if moving:
		return

	var random_direction   = directions.pick_random()
	var tiles_to_move: int = randi_range(1, max_tiles_per_move)

	ray_cast.target_position = random_direction * (tile_size * tiles_to_move)
	ray_cast.force_raycast_update()

	if !ray_cast.is_colliding():
		move(random_direction, tiles_to_move)
	else:
		on_movement_blocked()

func move(direction: Vector2, tiles: int) -> void:
	moving = true
	update_animation(direction)

	var tween: Tween = create_tween()
	var target_pos: Vector2 = position + direction * (tile_size * tiles)
	tween.tween_property(self, "position", target_pos, speed * tiles)
	tween.tween_callback(stop_moving)


func stop_moving() -> void:
	animated_sprite_2d.play("idle_down")
	moving = false


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
		timer.start()

func _on_dialogic_signal(arg: String):
	# Placeholder for NPC behavior
	pass

func on_movement_blocked():
	# Placeholder for specific NPC behavior when movement is blocked
	pass


func interact(player: Player):
	# Placeholder for interaction logic
	pass
