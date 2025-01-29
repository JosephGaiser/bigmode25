class_name Vendor
extends BaseNPC

var player: Player
var character: String = "vendor"

func setup_initial_state():
	super.setup_initial_state()
	toggle_wandering(false)


func on_movement_blocked():
	return


func interact(caller: Player):
	self.player = caller
	Dialogic.signal_event.connect(_on_dialogic_signal)
	Dialogic.timeline_ended.connect(_on_timeline_ended)
	var layout: Node = Dialogic.start("vendor")
	layout.register_character(self.character, animated_sprite_2d)

	# Disable wandering during interaction
	toggle_wandering(false)


func _on_timeline_ended():
	player.end_interaction()

func _on_dialogic_signal(arg: String):
	return
