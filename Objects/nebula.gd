class_name Nebula extends Resource

# Base type of the node
enum {EVENT, UNCLAIMED, SHOP, XARAGILN, NAMURANT}
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


func _init(type=null, mod=null) -> void:
	if type == null:
		# Type
		var data: Array = [UNCLAIMED, SHOP, NAMURANT, XARAGILN, EVENT]
		var weights: PackedFloat32Array = get_weights()
		# Choose type
		self.type = data[Global.random.rand_weighted(weights)]
	else:
		self.type = type
	
	if mod == null:
		# Play modifiers
		if (self.type == NAMURANT or self.type == XARAGILN) and Global.random.randf() < 0.2:
			# 20 % chance for under attack
			self.play_modifier = play_modifiers.UNDER_ATTACK
		else:
			if Global.random.randf() < 0.3:
				# 30 % chance for special
				self.play_modifier = play_modifiers.SPECIAL


static func generate_pool(n: int) -> Array[Nebula]:
	var pool: Array[Nebula] = []
	
	var data: Array = [UNCLAIMED, SHOP, NAMURANT, XARAGILN, EVENT]
	
	var weights = get_weights()
	
	var weight: float = 0.0
	for w in weights:
		weight += w
	
	for i in len(weights):
		var num = n * weights[i] / weight
		if num <= 1:
			pool.append(Nebula.new(data[i]))
		else:
			for j in floor(num):
				pool.append(Nebula.new(data[i]))
	for i in n - len(pool):
		pool.append(Nebula.new())
	return pool


static func get_weights() -> PackedFloat32Array:
	# Unclaimed, shop, nam, xar, event
	var weights: PackedFloat32Array = [3, 2, 6, 6, 3]
	
	if Global.is_namurant_friendly:
		weights[2] = 2
	if Global.is_xaragiln_friendly:
		weights[3] = 2
	
	return weights
