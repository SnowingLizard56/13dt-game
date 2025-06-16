extends Node

var num_regex: RegEx

func _ready() -> void:
	num_regex = RegEx.create_from_string(r'^([0-9]+(\.[0-9]+)?)$')
