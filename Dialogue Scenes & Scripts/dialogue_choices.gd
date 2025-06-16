class_name DialogueChoice extends MarginContainer

var _sentence: Sentence

signal option_chosen(key: String)


func display_options(sentence: Sentence) -> void:
	for key in sentence.choices:
		_sentence = sentence
		# Make
		var button: Button = Button.new()
		# Key is the name of option
		button.text = key
		print(get_children())
		get_child(0).add_child(button)
		size_flags_horizontal = Control.SIZE_EXPAND_FILL
		# When button pressed, emit option chosen with argument key
		button.pressed.connect(_on_button_pressed.bind(key))

func _on_button_pressed(key: String):
	option_chosen.emit(key)
