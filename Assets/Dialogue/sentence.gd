class_name Sentence extends Resource

@export_multiline var text: String = ""
@export var choices: Array[Prompt] = []
@export var delay: float = 0.2


func get_sentence(str:String = "") -> Array[Sentence]:
	return []
