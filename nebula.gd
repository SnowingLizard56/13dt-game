class_name Nebula extends Resource

# Base type of the node
enum {UNCLAIMED, SHOP, XARAGILN, NAMURANT}
var type := UNCLAIMED: 
	set(v):
		match v:
			XARAGILN:
				is_friendly = Global.is_xaragiln_friendly
			NAMURANT:
				is_friendly = Global.is_namurant_friendly
			_:
				is_friendly = true
		type = v

var is_friendly: bool

# Modifiers to level generation
var sparse: bool = false
var thick: bool = false
var dense: bool = false
var gaseous: bool = false
var rocky: bool = false

# Modifiers to playing
enum play_modifiers {NONE, UNDER_ATTACK, RECHART_COURSE}
var play_modifier: play_modifiers = play_modifiers.NONE

# Bodies. Handled by a GravityController.
var bodies: Dictionary[String, Variant]

# Connections
var connections: Array[Nebula]

# int pos
var cell_pos: Vector2i
