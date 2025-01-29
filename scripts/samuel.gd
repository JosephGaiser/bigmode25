class_name Samuel
extends BaseNPC

var player: Player
var character: String = "samuel"

func setup_initial_state():
	super.setup_initial_state()
	toggle_wandering(false)


func on_movement_blocked():
	animated_sprite_2d.play("read")


func interact(caller: Player):
	self.player = caller
	Dialogic.signal_event.connect(_on_dialogic_signal)
	Dialogic.timeline_ended.connect(_on_timeline_ended)
	var layout: Node = Dialogic.start("samuel")
	layout.register_character(self.character, animated_sprite_2d)

	# Disable wandering during interaction
	toggle_wandering(false)


func _on_timeline_ended():
	player.end_interaction()
	toggle_wandering(true)

func _on_dialogic_signal(arg: String):
	if arg == "read":
		animated_sprite_2d.play("read")
