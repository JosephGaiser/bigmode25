class_name Ui
extends Control

@onready var morale_bar: ProgressBar = $VBoxContainer/MoraleBar
@onready var profits_bar: ProgressBar = $VBoxContainer/ProfitsBar
@onready var reputation_bar: ProgressBar = $VBoxContainer/ReputationBar
@onready var authorithy_bar: ProgressBar = $VBoxContainer/AuthorithyBar

@onready var gameover_label: Label = $GameOver/gameover_label
@onready var reason_label: Label = $GameOver/reason_label

func _ready():
	gameover_label.visible = false
	reason_label.visible = false
	
	power_manager.update_ui_values.connect(Callable(self, "_on_update_ui_values"))
	power_manager.game_over.connect(_on_game_over)
	print("MoraleBar: ", morale_bar)
	print("ProfitsBar: ", profits_bar)
	print("ReputationBar: ", reputation_bar)
	print("AuthorithyBar: ", authorithy_bar)
	update_ui_values()

func _on_game_over(reason: String) -> void:
	gameover_label.visible = true
	reason_label.text = reason
	reason_label.visible = true
	return


func update_ui_values() -> void:
	var status: Dictionary = power_manager.get_current_status()
	if status.has("morale"):
		create_tween().tween_property(morale_bar, "value", float(status["morale"]), 0.5)
	if status.has("profits"):
		create_tween().tween_property(profits_bar, "value", float(status["profits"]), 0.5)
	if status.has("reputation"):
		create_tween().tween_property(reputation_bar, "value", float(status["reputation"]), 0.5)
	if status.has("authority"):
		create_tween().tween_property(authorithy_bar, "value", float(status["authority"]), 0.5)

func _on_update_ui_values():
	update_ui_values()
