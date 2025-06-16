class_name DialogueBox extends MarginContainer

signal display_finished

@export var dialogue_choices_scene: PackedScene
@onready var panel_container: PanelContainer = get_node("PanelContainer")
@onready var rich_text_label: RichTextLabel = get_node("PanelContainer/ReadText")
var max_size: float = 320.0
var _sentence: Sentence


func display_text(text: String, on_right: bool) -> void:
	# Put on other side
	if on_right:
		panel_container.size_flags_horizontal = Control.SIZE_SHRINK_END
	# Apply text
	rich_text_label.text = text
	rich_text_label.visible_characters = 0


func _process(delta: float) -> void:
	if rich_text_label.visible_characters != -1:
		rich_text_label.visible_characters += 1
	# Emit signal if finished
	if rich_text_label.get_total_character_count() == rich_text_label.visible_characters:
		rich_text_label.visible_characters = -1
		display_finished.emit()
	# If it doesn't fit, turn wrap on
	if panel_container.size.x > max_size:
		panel_container.custom_minimum_size.x = max_size
		rich_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
