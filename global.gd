extends Node


const PREDICTION_TIMESTEP: float = 5.0 / 8
var player_ship: Ship

var is_xaragiln_friendly: bool = false
var is_namurant_friendly: bool = true

var time_scale: float = 4.8e5

var mouse_aim: Vector2 = Vector2.RIGHT
var joy_aim: Vector2 = Vector2.ZERO
var aim: Vector2 = Vector2.ZERO
var mouse_stale := false
var joy_stale := true

var level_seed: int = 1

@onready var random: RandomNumberGenerator = RandomNumberGenerator.new()
signal frame_next

func process_sentence(sen:Sentence) -> String:
	var out = sen.text
	out = out.replace("{NAME}", "Player")
	return out


# Not my function. An algorithm essentially the same as Array.shuffle()
# Except it uses its own random number generator
func array_shuffle(array: Array) -> Array:
	# Each item except last two
	for i in len(array) - 2:
		# Swap it with a random index to the right
		var rand_idx = random.randi_range(i, len(array) - 1)
		var temp = array[rand_idx]
		array[rand_idx] = array[i]
		array[i] = temp
	return array


func _process(_delta: float) -> void:
	frame_next.emit()
	# Get each device aim
	var new_mouse: Vector2 = (get_viewport().get_mouse_position() -\
		get_viewport().get_visible_rect().get_center()).normalized()
	if new_mouse == mouse_aim:
		mouse_stale = true
	else:
		mouse_aim = new_mouse
		mouse_stale = false
	
	var new_joy: Vector2 = Vector2(Input.get_axis("aim_left", "aim_right"), 
		Input.get_axis("aim_up", "aim_down"))
	if new_joy == joy_aim:
		joy_stale = true
	else:
		joy_aim = new_joy
		joy_stale = false
	
	# Decide which to use
	if !joy_stale:
		aim = joy_aim
	elif joy_stale and !mouse_stale:
		aim = mouse_aim
	
