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
enum play_modifiers {NONE, UNDER_ATTACK, SPECIAL}
var play_modifier: play_modifiers = play_modifiers.NONE

# Bodies. Handled by a GravityController.
var bodies: Dictionary[String, Variant]


static func random() -> Nebula:
	var out: Nebula = Nebula.new()
	
	# Type
	var data: Array = [UNCLAIMED, SHOP, NAMURANT, XARAGILN]
	var weights: PackedFloat32Array = PackedFloat32Array([3, 1, 7, 7])
	
	if Global.is_namurant_friendly:
		weights[2] = 1
	if Global.is_xaragiln_friendly:
		weights[3] = 1
	
	# Choose type
	out.type = data[Global.random.rand_weighted(weights)]
	
	# Play modifiers
	if (out.type == NAMURANT or out.type == XARAGILN) and Global.random.randf() < 0.2:
		# 20 % chance for under attack
		out.play_modifier = play_modifiers.UNDER_ATTACK
	else:
		if Global.random.randf() < 0.3:
			# 30 % chance for rechart
			out.play_modifier = play_modifiers.SPECIAL
	
	# Level generation
	
	return out
	
