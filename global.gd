extends Node


var is_xaragiln_friendly: bool = false
var is_namurant_friendly: bool = true

var random: RandomNumberGenerator


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
