class_name Carl
extends BaseNPC

var player : Player
var character: String = "Carl"

func setup_initial_state():
	super.setup_initial_state()
	self.max_tiles_per_move = 2
	toggle_wandering(true)


func on_movement_blocked():
	animated_sprite_2d.play("clean")


func interact(caller: Player):
	self.player = caller
	Dialogic.signal_event.connect(_on_dialogic_signal)
	Dialogic.timeline_ended.connect(_on_timeline_ended)
	var layout: Node = Dialogic.start("CarlCleaning")
	layout.register_character(self.character, animated_sprite_2d)

	# Disable wandering during interaction
	toggle_wandering(false)

func _on_timeline_ended():
	player.end_interaction()
	toggle_wandering(true)

func _on_dialogic_signal(arg: String):
	return
