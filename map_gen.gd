extends Node2D

func _ready() -> void:
	generate_map(1)


func generate_map(seed:int):
	var random: RandomNumberGenerator = RandomNumberGenerator.new()
	random.seed = seed
	# How many cells
	var cell_count: int = [14, 17, 19, 23].pick_random()
	# Create map
	var bitmap: BitMap = BitMap.new()
	bitmap.create(Vector2i(7, 5))
	
	var rep: int = 0
	
	while cell_count > 0:
		var pos: int = randi() % 35
		# If a cell is already there, retry
		if bitmap.get_bit(pos % 7, pos / 7):
			rep += 1
			continue
		# This has potential to go on forever but it shouldnt
		bitmap.set_bit(pos % 7, pos / 7, true)
		cell_count -= 1
		var n: Nebula = Nebula.new()
	
	for i in bitmap.get_size().y:
		var line: String = ""
		for j in bitmap.get_size().x:
			if bitmap.get_bit(j, i):
				line += "."
			else:
				line += " "
		print("|"+line+"|")
