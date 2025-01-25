class_name Carl
extends  Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _ready():
    animated_sprite_2d.play("idle_down")


func interact():
    Dialogic.Styles.load_style("custom_bubble")
    var layout: Node = Dialogic.start("CarlCleaning")
    layout.register_character("Carl", animated_sprite_2d)
