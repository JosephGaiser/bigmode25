class_name Billy
extends BaseNPC

var player : Player
var character: String = "billy"


func setup_initial_state():
	super.setup_initial_state()
	toggle_wandering(false)


func on_movement_blocked():
	animated_sprite_2d.play("phone")


func interact(caller: Player):
	self.player = caller
	Dialogic.signal_event.connect(_on_dialogic_signal)
	Dialogic.timeline_ended.connect(_on_timeline_ended)
	var layout: Node = Dialogic.start("BillyTech")
	layout.register_character(self.character, animated_sprite_2d)

	# Disable wandering during interaction
	toggle_wandering(false)

func _on_timeline_ended():
	player.end_interaction()
	toggle_wandering(true)

func _on_dialogic_signal(arg: String):
	return
