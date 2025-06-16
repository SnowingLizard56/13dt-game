class_name DialogueBox extends MarginContainer

signal display_finished

@export var panel_container: PanelContainer
@export var rich_text_label: RichTextLabel


func display_text(string:String, on_right: bool) -> void:
	# Put on other side
	if on_right:
		panel_container.size_flags_horizontal = Control.SIZE_SHRINK_END
	# Apply text
	rich_text_label.text = string
	rich_text_label.visible_characters = 0


func _process(delta: float) -> void:
	rich_text_label.visible_characters += 1
	# Emit signal if finished
	if rich_text_label.get_total_character_count() == rich_text_label.visible_characters:
		display_finished.emit()
	# If it doesn't fit, turn wrap on
	if panel_container.size.x > panel_container.custom_minimum_size.x:
		rich_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
