class_name Billy
extends BaseNPC

var player : Player

func setup_initial_state():
	super.setup_initial_state()


func on_movement_blocked():
	animated_sprite_2d.play("phone")


func interact(caller: Player):
	self.player = caller
	Dialogic.Styles.load_style("custom_bubble")
	Dialogic.signal_event.connect(_on_dialogic_signal)
	var layout: Node = Dialogic.start("BillyTech")
	layout.register_character("billy", animated_sprite_2d)

	# Disable wandering during interaction
	toggle_wandering(false)

func _on_dialogic_signal(arg: String):
	if arg == "end":
		player.end_interaction()
		toggle_wandering(true)
