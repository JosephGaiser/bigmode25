class_name Day_2
extends BaseDay

func _ready() -> void:
	end_day_timeline = "director_day_2_end"
	day = "tuesday"
	super._ready()


func _get_completion_conditions() -> bool:
	return Dialogic.VAR.Rae.day_2 \
	and Dialogic.VAR.Billy.day_2 \
	and Dialogic.VAR.Carl.day_2 \
	and Dialogic.VAR.Chet.day_2 \
	and Dialogic.VAR.Samuel.day_2
