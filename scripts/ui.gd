class_name Ui
extends Control

@onready var morale_bar: ProgressBar = $VBoxContainer/MoraleBar
@onready var profits_bar: ProgressBar = $VBoxContainer/ProfitsBar
@onready var reputation_bar: ProgressBar = $VBoxContainer/ReputationBar
@onready var authorithy_bar: ProgressBar = $VBoxContainer/AuthorithyBar

func _ready():
	power_manager.connect("update_ui_values", Callable(self, "_on_update_ui_values"))
	power_manager.connect("game_over", _on_update_ui_values)
	print("MoraleBar: ", morale_bar)
	print("ProfitsBar: ", profits_bar)
	print("ReputationBar: ", reputation_bar)
	print("AuthorithyBar: ", authorithy_bar)
	update_ui_values()


func update_ui_values() -> void:
	var status: Dictionary = power_manager.get_current_status()
	if status.has("morale"):
		morale_bar.value = float(status["morale"])
	if status.has("profits"):
		profits_bar.value = float(status["profits"])
	if status.has("reputation"):
		reputation_bar.value = float(status["reputation"])
	if status.has("authority"):
		authorithy_bar.value = float(status["authority"])

func _on_update_ui_values():
	update_ui_values()
