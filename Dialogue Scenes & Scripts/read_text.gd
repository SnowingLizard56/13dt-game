extends Control

@export_file("*.txt") var file_path: String = "res://Assets/Dialogue/TestDialogue.txt"
@export var dialogue_box_scene: PackedScene
@export var dialogue_choice_scene: PackedScene
@export var delay_timer: Timer
@export var content: Dialogue
var sentence_queue: Array[Sentence]

signal finish_sequence


func _ready() -> void:
	# Display. Testing purposes.
	# TEST
	next_content()


func next_content() -> void:
	# Replenish Sentence queue
	if sentence_queue.is_empty():
		# If cant, then the sequence is finished. return
		if content.sentences.is_empty():
			finish_sequence.emit()
			return
		# But if can, move sentence from content.sentences to sentence_queue
		sentence_queue.push_front(content.sentences[0])
		content.sentences.pop_front()
	
	# Operate on sentence_queue[0]
	if sentence_queue[0].text != "":
		# Display sentence text
		var dialogue_box: DialogueBox = dialogue_box_scene.instantiate()
		$VBoxContainer.add_child(dialogue_box)
		# Call display, connect finished with next display.
		dialogue_box.display_text(sentence_queue[0].text, false)
		dialogue_box._sentence = sentence_queue[0]
		# If no choices, connect display back to this
		if len(sentence_queue[0].choices) == 0:
			dialogue_box.display_finished.connect(next_content)
	
	# If there are choices and no text
	if (len(sentence_queue[0].choices) != 0 and sentence_queue[0].text == ""):
		# Make dialogue Choices
		var dialogue_choices: DialogueChoice = dialogue_choice_scene.instantiate()
		$VBoxContainer.add_child(dialogue_choices)
		dialogue_choices.display_options(sentence_queue[0])
	
	# Remove displayed sentence from queue.
	sentence_queue.pop_back()


func dialogue_option_chosen(_sentence: Sentence, key: String):
	sentence_queue.append_array(_sentence.get_sentence(key))
	# Display key on right side.
	var dialogue_box: DialogueBox = dialogue_box_scene.instantiate()
	$VBoxContainer.add_child(dialogue_box)
	# Call display, connect finished with next display.
	dialogue_box.display_text(key, true)
	dialogue_box.display_finished.connect(next_content)
	
