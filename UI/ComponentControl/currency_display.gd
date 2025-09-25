class_name CurrencyDisplay extends Control

const SOLID_COLOUR: Color = Color(0.961, 0.91, 0.82, 1.0)
const ENEMY_COLOUR: Color = Color(0.867, 0.337, 0.224, 1.0)
@export var length := 6
@export var max_val := 999999
@onready var label: Label = $Currency
var value: int


func apply_amount(v: int):
	value = v
	if v < 0:
		v = -v
		label.modulate = ENEMY_COLOUR
	else:
		label.modulate = SOLID_COLOUR
	v = min(v, max_val)
	var out: String = str(v)
	
	if len(out) < length:
		out = "0".repeat(length - len(out)) + out
	label.text = out
