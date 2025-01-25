class_name Player
extends CharacterBody2D

var input_dir: Vector2 = Vector2.ZERO
var last_dir: Vector2 = Vector2.ZERO

var tile_size: int     = 16
var moving: bool       = false

@export var speed: float = .4

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _ready():
	animated_sprite_2d.play("idle_down")


func _physics_process(delta: float) -> void:
	input_dir = Vector2.ZERO
	if Input.is_action_pressed("move_up") && input_dir != Vector2.UP:
		input_dir = Vector2.UP
		move()
	elif Input.is_action_pressed("move_down") && input_dir != Vector2.DOWN:
		input_dir = Vector2.DOWN
		move()
	elif Input.is_action_pressed("move_left") && input_dir != Vector2.LEFT:
		input_dir = Vector2.LEFT
		move()
	elif Input.is_action_pressed("move_right") && input_dir != Vector2.RIGHT:
		input_dir = Vector2.RIGHT
		move()

	move_and_slide()


# Grid based movement logic
func move() -> void:
	if !input_dir || moving:
		return

	self.last_dir = input_dir
	match input_dir:
		Vector2.UP:
			animated_sprite_2d.play("walk_up")
		Vector2.DOWN:
			animated_sprite_2d.play("walk_down")
		Vector2.LEFT:
			animated_sprite_2d.play("walk_left")
		Vector2.RIGHT:
			animated_sprite_2d.play("walk_right")
		Vector2.ZERO:
			animated_sprite_2d.play("idle_down")

	moving = true
	var tween: Tween        = create_tween()
	var target_pos: Vector2 = self.position + input_dir * tile_size
	tween.tween_property(self, "position", target_pos, self.speed)
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
