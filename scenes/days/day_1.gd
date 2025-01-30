class_name Day_1
extends BaseDay

func _ready() -> void:
	end_day_timeline = "day_1_end"
	day = "monday"
	super._ready()


func _get_completion_conditions() -> bool:
	return Dialogic.VAR.Rae.day_1 \
	and Dialogic.VAR.Billy.day_1 \
	and Dialogic.VAR.Carl.day_1 \
	and Dialogic.VAR.Chet.day_1 \
	and Dialogic.VAR.Samuel.day_1
