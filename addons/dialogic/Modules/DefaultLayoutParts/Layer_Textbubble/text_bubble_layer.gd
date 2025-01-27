@tool
extends DialogicLayoutLayer

## This layout won't do anything on its own

@export_group("Main")
@export_subgroup("Text")
@export var text_size: int = 15
@export var text_color: Color = Color.BLACK
@export_file('*.ttf') var normal_font: String = ""
@export_file('*.ttf') var bold_font: String = ""
@export_file('*.ttf') var italic_font: String = ""
@export_file('*.ttf') var bold_italic_font: String = ""
@export var text_max_width: int = 300

@export_subgroup('Box')
@export var box_modulate: Color = Color.WHITE
@export var box_modulate_by_character_color: bool = false
@export var box_padding: Vector2 = Vector2(10,10)
@export_range(1, 999) var box_corner_radius: int = 25
@export_range(0.1, 5) var box_wobble_speed: float = 1
@export_range(0, 1) var box_wobble_amount: float = 0.5
@export_range(0, 1) var box_wobble_detail: float = 0.2

@export_subgroup('Behaviour')
@export var behaviour_distance: int = 50
@export var behaviour_direction: Vector2 = Vector2(1, -1)

@export_group('Name Label')
@export_subgroup("Name Label")
@export var name_label_enabled: bool = true
@export var name_label_font_size: int = 15
@export_file('*.ttf') var name_label_font: String = ""
@export var name_label_use_character_color: bool = true
@export var name_label_color: Color = Color.BLACK
@export_subgroup("Name Label Box")
@export var name_label_box_modulate: Color = Color.WHITE
@export var name_label_box_modulate_use_character_color: bool = false
@export var name_label_padding: Vector2 = Vector2(5,0)
@export var name_label_offset: Vector2 = Vector2(0,0)
@export var name_label_alignment := HBoxContainer.ALIGNMENT_BEGIN


@export_group('Choices')
@export_subgroup('Choices Text')
@export var choices_text_size: int = 15
@export_file('*.ttf') var choices_text_font: String = ""
@export var choices_text_color: Color = Color.DARK_SLATE_GRAY
@export var choices_text_color_hover: Color = Color.DARK_MAGENTA
@export var choices_text_color_focus: Color = Color.DARK_MAGENTA
@export var choices_text_color_disabled: Color = Color.DARK_GRAY

@export_subgroup('Choices Layout')
@export var choices_layout_alignment := FlowContainer.ALIGNMENT_END
@export var choices_layout_force_lines: bool = false
@export_file('*.tres', "*.res") var choices_base_theme: String = ""


@export_group('Sounds')

@export_subgroup('Typing Sounds')
@export var typing_sounds_enabled: bool = true
@export var typing_sounds_mode: DialogicNode_TypeSounds.Modes = DialogicNode_TypeSounds.Modes.INTERRUPT
@export_dir var typing_sounds_sounds_folder: String = "res://addons/dialogic/Example Assets/sound-effects/"
@export_file("*.wav", "*.ogg", "*.mp3") var typing_sounds_end_sound: String = ""
@export_range(1, 999, 1) var typing_sounds_every_nths_character: int = 1
@export_range(0.01, 4, 0.01) var typing_sounds_pitch: float = 1.0
@export_range(0.0, 3.0) var typing_sounds_pitch_variance: float = 0.0
@export_range(-80, 24, 0.01) var typing_sounds_volume: float = -10
@export_range(0.0, 10) var typing_sounds_volume_variance: float = 0.0
@export var typing_sounds_ignore_characters: String = " .,!?"

const TextBubble := preload("res://addons/dialogic/Modules/DefaultLayoutParts/Layer_Textbubble/text_bubble.gd")

var bubbles: Array[TextBubble] = []
var fallback_bubble: TextBubble = null

const textbubble_scene: PackedScene = preload("res://addons/dialogic/Modules/DefaultLayoutParts/Layer_Textbubble/text_bubble.tscn")


func add_bubble() -> TextBubble:
	var new_bubble: TextBubble = textbubble_scene.instantiate()
	add_child(new_bubble)
	bubbles.append(new_bubble)
	return new_bubble


## Called by dialogic whenever export overrides might change
func _apply_export_overrides() -> void:
	pass



## Called by the base layer before opening the bubble
func bubble_apply_overrides(bubble:TextBubble) -> void:
	## TEXT FONT AND COLOR
	var rtl: RichTextLabel = bubble.text
	rtl.add_theme_font_size_override(&'normal_font', text_size)
	rtl.add_theme_font_size_override(&"normal_font_size", text_size)
	rtl.add_theme_font_size_override(&"bold_font_size", text_size)
	rtl.add_theme_font_size_override(&"italics_font_size", text_size)
	rtl.add_theme_font_size_override(&"bold_italics_font_size", text_size)

	rtl.add_theme_color_override(&"default_color", text_color)

	if !normal_font.is_empty():
		rtl.add_theme_font_override(&"normal_font", load(normal_font) as Font)
	if !bold_font.is_empty():
		rtl.add_theme_font_override(&"bold_font", load(bold_font) as Font)
	if !italic_font.is_empty():
		rtl.add_theme_font_override(&"italitc_font", load(italic_font) as Font)
	if !bold_italic_font.is_empty():
		rtl.add_theme_font_override(&"bold_italics_font", load(bold_italic_font) as Font)
	bubble.set(&'max_width', text_max_width)


	## BOX & TAIL COLOR
	var tail_and_bg_group := (bubble.get_node("Group") as CanvasGroup)
	tail_and_bg_group.self_modulate = box_modulate
	if box_modulate_by_character_color and bubble.current_character != null:
		tail_and_bg_group.self_modulate = bubble.current_character.color

	var background := (bubble.get_node('%Background') as ColorRect)
	var bg_material: ShaderMaterial = (background.material as ShaderMaterial)
	bg_material.set_shader_parameter(&'radius', box_corner_radius)
	bg_material.set_shader_parameter(&'wobble_amount', box_wobble_amount)
	bg_material.set_shader_parameter(&'wobble_speed', box_wobble_speed)
	bg_material.set_shader_parameter(&'wobble_detail', box_wobble_detail)

	bubble.padding = box_padding


	## BEHAVIOUR
	bubble.safe_zone = behaviour_distance
	bubble.base_direction = behaviour_direction


	## NAME LABEL SETTINGS
	var nl: DialogicNode_NameLabel = bubble.name_label
	nl.add_theme_font_size_override(&"font_size", name_label_font_size)

	if !name_label_font.is_empty():
		nl.add_theme_font_override(&'font', load(name_label_font) as Font)


	if name_label_use_character_color and bubble.current_character:
		nl.add_theme_color_override(&"font_color", bubble.current_character.color)
	else:
		nl.add_theme_color_override(&"font_color", name_label_color)

	var nlp: PanelContainer = bubble.name_label_box
	nlp.self_modulate = name_label_box_modulate
	if name_label_box_modulate_use_character_color and bubble.current_character:
		nlp.self_modulate = bubble.current_character.color
	nlp.get_theme_stylebox(&'panel').content_margin_left = name_label_padding.x
	nlp.get_theme_stylebox(&'panel').content_margin_right = name_label_padding.x
	nlp.get_theme_stylebox(&'panel').content_margin_top = name_label_padding.y
	nlp.get_theme_stylebox(&'panel').content_margin_bottom = name_label_padding.y
	bubble.name_label_offset = name_label_offset
	bubble.name_label_alignment = name_label_alignment

	nlp.get_parent().visible = name_label_enabled

	## CHOICE SETTINGS
	if choices_layout_force_lines:
		bubble.add_choice_container(VBoxContainer.new(), choices_layout_alignment)
	else:
		bubble.add_choice_container(HFlowContainer.new(), choices_layout_alignment)

	var choice_theme: Theme = null
	if choices_base_theme.is_empty() or not ResourceLoader.exists(choices_base_theme):
		choice_theme = Theme.new()
		var base_style := StyleBoxFlat.new()
		base_style.draw_center = false
		base_style.border_width_bottom = 2
		base_style.border_color = choices_text_color
		choice_theme.set_stylebox(&'normal', &'Button', base_style)
		var focus_style := (base_style.duplicate() as StyleBoxFlat)
		focus_style.border_color = choices_text_color_focus
		choice_theme.set_stylebox(&'focus', &'Button', focus_style)
		var hover_style := (base_style.duplicate() as StyleBoxFlat)
		hover_style.border_color = choices_text_color_hover
		choice_theme.set_stylebox(&'hover', &'Button', hover_style)
		var disabled_style := (base_style.duplicate() as StyleBoxFlat)
		disabled_style.border_color = choices_text_color_disabled
		choice_theme.set_stylebox(&'disabled', &'Button', disabled_style)
		choice_theme.set_stylebox(&'pressed', &'Button', base_style)
	else:
		choice_theme = (load(choices_base_theme) as Theme)

	if !choices_text_font.is_empty():
		choice_theme.default_font = (load(choices_text_font) as Font)

	choice_theme.set_font_size(&'font_size', &'Button', choices_text_size)
	choice_theme.set_color(&'font_color', &'Button', choices_text_color)
	choice_theme.set_color(&'font_pressed_color', &'Button', choices_text_color)
	choice_theme.set_color(&'font_hover_color', &'Button', choices_text_color_hover)
	choice_theme.set_color(&'font_focus_color', &'Button', choices_text_color_focus)
	choice_theme.set_color(&'font_disabled_color', &'Button', choices_text_color_disabled)
	bubble.choice_container.theme = choice_theme
	
	## TYPING SOUNDS
	_apply_sounds_settings()

## Applies all sound settings to the scene.
func _apply_sounds_settings() -> void:
	var type_sounds: DialogicNode_TypeSounds = %DialogicNode_TypeSounds_Bubble
	type_sounds.enabled = typing_sounds_enabled
	type_sounds.mode = typing_sounds_mode

	if not typing_sounds_sounds_folder.is_empty():
		type_sounds.sounds = DialogicNode_TypeSounds.load_sounds_from_path(typing_sounds_sounds_folder)
	else:
		type_sounds.sounds.clear()

	if not typing_sounds_end_sound.is_empty():
		type_sounds.end_sound = load(typing_sounds_end_sound)
	else:
		type_sounds.end_sound = null

	type_sounds.play_every_character = typing_sounds_every_nths_character
	type_sounds.base_pitch = typing_sounds_pitch
	type_sounds.base_volume = typing_sounds_volume
	type_sounds.pitch_variance = typing_sounds_pitch_variance
	type_sounds.volume_variance = typing_sounds_volume_variance
	type_sounds.ignore_characters = typing_sounds_ignore_characters
