extends Node

func process_sentence(sen:Sentence) -> String:
	var out = sen.text
	out = out.replace("{NAME}", "Player")
	#out.replace("{NAME}", "Player")
	#out.replace("{NAME}", "Player")
	return out
