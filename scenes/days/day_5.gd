class_name Day_5
extends BaseDay

func _ready() -> void:
	end_day_timeline = "day_5_end"
	day = "friday"
	super._ready()


func _get_completion_conditions() -> bool:
	return Dialogic.VAR.Director.day_5
