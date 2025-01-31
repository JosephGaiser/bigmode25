class_name Carl
extends BaseNPC

@export var clone_name: String = "Carl"

var player : Player
var character: String = "Carl"

func setup_initial_state():
	super.setup_initial_state()
	self.max_tiles_per_move = 2


func on_movement_blocked():
	self.animated_sprite_2d.play("clean")


func interact(caller: Player):
	self.player = caller
	Dialogic.signal_event.connect(_on_dialogic_signal)
	Dialogic.timeline_ended.connect(_on_timeline_ended, CONNECT_ONE_SHOT)
	var layout: Node = Dialogic.start(self.current_timeline)
	if self.clone_name:
		layout.register_character(self.clone_name, self.animated_sprite_2d)
	else:
		layout.register_character(self.character, self.animated_sprite_2d)

	# Disable wandering during interaction
	toggle_wandering(false)

func _on_timeline_ended():
	player.end_interaction()
	if clone_name != "Carl":
		return
	toggle_wandering(true)

func _on_dialogic_signal(arg: String):
	return
