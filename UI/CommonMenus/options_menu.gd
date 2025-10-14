class_name OptionsMenu extends Control


func _draw() -> void:
	# Update to what is set in GlobalOptions
	pass


func _on_audio_drag_ended(value_changed: bool) -> void:
	if value_changed:
		# Update volume
		pass


func _on_done_pressed() -> void:
	# Store to config
	# Apply everything
	# Emit done
	pass
