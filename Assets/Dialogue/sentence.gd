class_name Sentence extends Resource

@export_multiline var text: String = ""
@export var choices: Dictionary[String, Sentence] = {}


func get_sentence(str:String = "") -> Array[Sentence]:
	var out: Array[Sentence] = []
	for s:String in choices[str].text.split("\n\n"):
		out.push_back(Sentence.new())
		out[-1].text = s
	return out
		
