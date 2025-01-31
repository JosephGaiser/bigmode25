class_name Day_3
extends BaseDay

@onready var rae = $rae
@onready var billy = $billy
@onready var carl = $Carl
@onready var chet = $chet
@onready var vendor = $vendor
@onready var samuel = $samuel


func _ready() -> void:
	if Dialogic.VAR.fired == "samuel":
		samuel.queue_free()
	if Dialogic.VAR.fired == "chet":
		chet.queue_free()
	if Dialogic.VAR.fired == "billy":
		billy.queue_free()
	if Dialogic.VAR.fired == "vendor":
		vendor.queue_free()
	end_day_timeline = "day_3_end"
	day = "wednesday"
	super._ready()
	start_office_party()


func _get_completion_conditions() -> bool:
	return Dialogic.VAR.party_over


func start_office_party():
	await get_tree().create_timer(3.0).timeout

	var layout: Node = Dialogic.start("birthday_meeting")
	layout.register_character("Rae", rae.animated_sprite_2d)
	layout.register_character("Carl", carl.animated_sprite_2d)
	if Dialogic.VAR.fired != "samuel":
		layout.register_character("samuel", samuel.animated_sprite_2d)
	if Dialogic.VAR.fired != "chet":
		layout.register_character("chet", chet.animated_sprite_2d)
	if Dialogic.VAR.fired != "billy":
		layout.register_character("billy", billy.animated_sprite_2d)
	if Dialogic.VAR.fired != "vendor":
		layout.register_character("vendor", vendor.animated_sprite_2d)
