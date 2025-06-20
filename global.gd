extends Node


var is_xaragiln_friendly: bool = false
var is_namurant_friendly: bool = true

var random: RandomNumberGenerator

func process_sentence(sen:Sentence) -> String:
	var out = sen.text
	out = out.replace("{NAME}", "Player")
	#out.replace("{NAME}", "Player")
	#out.replace("{NAME}", "Player")
	return out
