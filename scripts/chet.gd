class_name Chet
extends BaseNPC

var player : Player

func setup_initial_state():
	super.setup_initial_state()


func on_movement_blocked():
	animated_sprite_2d.play("read")


func interact(caller: Player):
	self.player = caller
	Dialogic.Styles.load_style("custom_bubble")
	Dialogic.signal_event.connect(_on_dialogic_signal)
	var layout: Node = Dialogic.start("ChetChurch")
	layout.register_character("chet", animated_sprite_2d)

	# Disable wandering during interaction
	toggle_wandering(false)

func _on_dialogic_signal(arg: String):
	if arg == "read":
		animated_sprite_2d.play("read")
	if arg == "end":
		player.end_interaction()
		toggle_wandering(true)
