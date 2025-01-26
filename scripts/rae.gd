class_name Rae
extends BaseNPC

var player: Player
var character: String = "Rae"


func setup_initial_state():
    super.setup_initial_state()
    toggle_wandering(false)


func on_movement_blocked() -> void:
    return


func interact(caller: Player):
    toggle_wandering(false)
    self.player = caller
    Dialogic.signal_event.connect(_on_dialogic_signal)
    var layout: Node = Dialogic.start("RaePinter")
    layout.register_character(self.character, animated_sprite_2d)


func _on_dialogic_signal(arg: String):
    if arg == "end":
        player.end_interaction()
        toggle_wandering(true)
