class_name Player
extends CharacterBody2D

var input_dir: Vector2 = Vector2.ZERO
var last_dir: Vector2  = Vector2.ZERO

@export var tile_size: int = 16
@export var speed: float = .4

var moving: bool   = false
var can_move: bool = true
var interacting: bool = false

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast: RayCast2D = $RayCast2D
@onready var interaction_area: Area2D = $InteractionArea


func _ready():
	animated_sprite_2d.play("idle_down")


func _physics_process(delta: float) -> void:
	if !moving and !interacting:
		handle_movement_input()

	update_interaction_area()

	if Input.is_action_just_pressed("interact"):
		interact()

	move_and_slide()


func update_interaction_area() -> void:
	match last_dir:
		Vector2.UP:
			interaction_area.position = Vector2(0, -tile_size)
		Vector2.DOWN:
			interaction_area.position = Vector2(0, tile_size)
		Vector2.LEFT:
			interaction_area.position = Vector2(-tile_size, 0)
		Vector2.RIGHT:
			interaction_area.position = Vector2(tile_size, 0)


func handle_movement_input() -> void:
	if Input.is_action_pressed("move_up"):
		try_change_direction(Vector2.UP)
	elif Input.is_action_pressed("move_down"):
		try_change_direction(Vector2.DOWN)
	elif Input.is_action_pressed("move_left"):
		try_change_direction(Vector2.LEFT)
	elif Input.is_action_pressed("move_right"):
		try_change_direction(Vector2.RIGHT)


func try_change_direction(direction: Vector2) -> void:
	last_dir = direction
	update_animation(direction)

	ray_cast.target_position = direction * tile_size
	ray_cast.force_raycast_update()

	if !ray_cast.is_colliding():
		move(direction)


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

	if !animated_sprite_2d.is_playing() or animated_sprite_2d.animation != anim_name:
		animated_sprite_2d.play(anim_name)


func move(direction: Vector2) -> void:
	moving = true

	var tween: Tween        = create_tween()
	var target_pos: Vector2 = position + direction * tile_size
	tween.tween_property(self, "position", target_pos, speed)
	tween.tween_callback(stop_moving)


func stop_moving() -> void:
	match last_dir:
		Vector2.UP:
			animated_sprite_2d.play("idle_up")
		Vector2.DOWN:
			animated_sprite_2d.play("idle_down")
		Vector2.LEFT:
			animated_sprite_2d.play("idle_left")
		Vector2.RIGHT:
			animated_sprite_2d.play("idle_right")

	moving = false


func interact() -> void:
	var interactables: Array[Node2D] = interaction_area.get_overlapping_bodies()
	for obj in interactables:
		if obj.has_method("interact"):
			interacting = true
			obj.call("interact", self)
			break

func end_interaction():
	interacting = false
