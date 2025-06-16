class_name DialogueChoice extends MarginContainer

var _sentence: Sentence

signal option_chosen(key: String)


func display_options(sentence: Sentence) -> void:
	for prompt in sentence.choices:
		_sentence = sentence
		# Make
		var button: Button = Button.new()
		# Key is the name of option
		button.text = prompt.prompt
		get_child(0).add_child(button)
		size_flags_horizontal = Control.SIZE_EXPAND_FILL
		# When button pressed, emit option chosen with argument key
		button.pressed.connect(_on_button_pressed.bind(prompt))


func _on_button_pressed(prompt: Prompt):
	# Disable buttons
	for b:Button in get_child(0).get_children():
		b.disabled = true
	# Emit option chosen
	option_chosen.emit(prompt)
