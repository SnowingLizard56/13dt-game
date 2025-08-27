class_name CurrencyDisplay extends Control

const SOLID_COLOUR: Color = Color(0.961, 0.91, 0.82, 1.0)
const ENEMY_COLOUR: Color = Color(0.867, 0.337, 0.224, 1.0)
@onready var label: Label = $Currency


func _ready() -> void:
	label.modulate = SOLID_COLOUR


func apply_amount(v: int):
	if v < 0:
		v = -v
		label.modulate = ENEMY_COLOUR
	else:
		label.modulate = SOLID_COLOUR
	v = min(v, 999999)
	var out: String = str(v)
	
	if len(out) < 6:
		out = "0".repeat(6 - len(out)) + out
	label.text = out


func _process(delta: float) -> void:
	apply_amount(Global.player_currency)
