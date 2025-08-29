class_name CurrencyDisplay extends Control

const SOLID_COLOUR: Color = Color(0.961, 0.91, 0.82, 1.0)
const ENEMY_COLOUR: Color = Color(0.867, 0.337, 0.224, 1.0)
const LENGTH := 6
const MAX := 999999
@onready var label: Label = $Currency


func apply_amount(v: int):
	if v < 0:
		v = -v
		label.modulate = ENEMY_COLOUR
	else:
		label.modulate = SOLID_COLOUR
	v = min(v, MAX)
	var out: String = str(v)
	
	if len(out) < LENGTH:
		out = "0".repeat(LENGTH - len(out)) + out
	label.text = out
