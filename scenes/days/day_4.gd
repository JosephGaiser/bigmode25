class_name Day_4
extends BaseDay

@onready var carl = $Carl
@onready var chet_clone = $ChetClone
@onready var rae_clone = $RaeClone
@onready var billy_clone = $BillyClone
@onready var samuel_clone = $SamuelClone
@onready var vendor_clone = $VendorClone

func _ready() -> void:
	#if Dialogic.VAR.fired == "samuel":
		#samuel_clone.queue_free()
	#if Dialogic.VAR.fired == "chet":
		#chet_clone.queue_free()
	#if Dialogic.VAR.fired == "billy":
		#billy_clone.queue_free()
	#if Dialogic.VAR.fired == "vendor":
		#vendor_clone.queue_free()
	
	end_day_timeline = "day_4_end"
	day = "thursday"
	super._ready()


func _get_completion_conditions() -> bool:
	return Dialogic.VAR.finished_clone_puzzle
