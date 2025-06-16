extends MarginContainer

func display_options(choices: Array[String]) -> void:
	for i in choices:
		# Make
		var button: Button = Button.new()
		# All but leftmost is the text
		button.text = i.right(-1)
		$HBoxContainer.add_child(button)
		size_flags_horizontal = Control.SIZE_EXPAND_FILL
