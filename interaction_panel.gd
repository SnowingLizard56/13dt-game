extends Control


@export var person_buttons: ButtonGroup


func _on_minthe_pressed() -> void:
	$TabContainer.current_tab = 0


func _on_baluma_pressed() -> void:
	$TabContainer.current_tab = 1


func _on_kiki_pressed() -> void:
	$TabContainer.current_tab = 2


func _on_s_pressed() -> void:
	$TabContainer.current_tab = 3
