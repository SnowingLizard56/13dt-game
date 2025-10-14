extends Control

const SOLID_COLOUR: Color = Color(0.961, 0.91, 0.82, 1.0)
const ENEMY_COLOUR: Color = Color(0.867, 0.337, 0.224, 1.0)
@export var length := 3
@export var max_value := 999
@onready var label: Label = $Currency
var value: int


func apply_amount(v: int):
	value = v
	if v < 0:
		label.text = "-"
		v = -v
		label.modulate = ENEMY_COLOUR
	else:
		label.text = "+"
		label.modulate = SOLID_COLOUR
	# No more than 3 characters
	v = min(v, max_value)
	var out: String = str(v)
	
	# No less than 3 characters
	if len(out) < length:
		out = "0".repeat(length - len(out)) + out
	label.text += out
