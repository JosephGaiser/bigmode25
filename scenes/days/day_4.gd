class_name Day_4
extends BaseDay


func _ready() -> void:
	end_day_timeline = "day_4_end"
	day = "thursday"
	super._ready()


func _get_completion_conditions() -> bool:
	return Dialogic.VAR.Carl.day_4
