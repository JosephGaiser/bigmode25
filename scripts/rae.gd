class_name Rae
extends BaseNPC

var player: Player
var character: String = "Rae"


func setup_initial_state():
	super.setup_initial_state()


func on_movement_blocked() -> void:
	return


func interact(caller: Player):
	toggle_wandering(false)
	self.player = caller
	Dialogic.signal_event.connect(_on_dialogic_signal)
	Dialogic.timeline_ended.connect(_on_timeline_ended)
	var layout: Node = Dialogic.start(self.current_timeline)
	layout.register_character(self.character, animated_sprite_2d)


func _on_timeline_ended():
	player.end_interaction()
	toggle_wandering(true)

func _on_dialogic_signal(arg: String):
	return
