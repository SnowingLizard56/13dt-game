class_name Dialogue extends Resource

@export var sentences: Array[Sentence] = []
@export var random_sentence: bool = false

func get_sentence(index:int):
	if random_sentence:
		return sentences.pick_random()
	return sentences[index]
