class_name Nebula extends Resource

# Base type of the node
# Unclaimed, shop, nam, xar, event
const WEIGHTS: PackedFloat32Array = [1, 1, 6, 4]
# Type
const DATA: Array = [SHOP, NAMURANT, XARAGILN, EVENT]

enum {EVENT, UNCLAIMED, SHOP, XARAGILN, NAMURANT}
var type := UNCLAIMED

var is_friendly: bool


func _init(_type=null) -> void:
	if _type == null:
		# Choose type
		self.type = DATA[Global.random.rand_weighted(WEIGHTS)]
	else:
		self.type = _type


static func generate_pool(n: int) -> Array[Nebula]:
	var pool: Array[Nebula] = []
	
	var weight: float = 0.0
	for w in WEIGHTS:
		weight += w
	
	for i in len(WEIGHTS):
		var num = n * WEIGHTS[i] / weight
		if num <= 1:
			pool.append(Nebula.new(DATA[i]))
		else:
			for j in floor(num):
				pool.append(Nebula.new(DATA[i]))
	for i in n - len(pool):
		pool.append(Nebula.new())
	return pool
