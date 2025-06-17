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
	if content:
		next_content()


func next_content() -> void:
	# Replenish Sentence queue
	if sentence_queue.is_empty():
		# If cant, then the sequence is finished. return
		if content.sentences.is_empty():
			finish_sequence.emit()
			print("its so over")
			return
		# But if can, move sentence from content.sentences to sentence_queue
		sentence_queue.push_front(content.sentences[0])
		content.sentences.pop_front()
	
	# Operate on sentence_queue[-1]
	if sentence_queue[-1].text != "":
		# Display sentence text
		var dialogue_box: DialogueBox = dialogue_box_scene.instantiate()
		$VBoxContainer.add_child(dialogue_box)
		# Call display, connect finished with next display.
		dialogue_box.display_text(sentence_queue[-1].text, false)
		dialogue_box._sentence = sentence_queue[-1]
		
		if len(sentence_queue[-1].choices) != 0:
			sentence_queue[-1].text = ""
			# Skip removal this time around.
			sentence_queue.push_back(Sentence.new())
		
		# Connect display finished back to this function
		dialogue_box.display_finished.connect(delay_timer.start.bind(sentence_queue[-1].delay))
	# If there are choices and no text
	elif len(sentence_queue[-1].choices) != 0:
		# Make dialogue Choices node
		var dialogue_choices: DialogueChoice = dialogue_choice_scene.instantiate()
		$VBoxContainer.add_child(dialogue_choices)
		# call setup function
		dialogue_choices.display_options(sentence_queue[-1])
		# connect to function called once compelte
		dialogue_choices.option_chosen.connect(dialogue_option_chosen)
	
	# Remove displayed sentence from queue.
	sentence_queue.pop_back()


func dialogue_option_chosen(prompt: Prompt):
	# Add sentence to sentence queue
	prompt.sentences.reverse()
	sentence_queue.append_array(prompt.sentences)
	# Display key on right side.
	var dialogue_box: DialogueBox = dialogue_box_scene.instantiate()
	$VBoxContainer.add_child(dialogue_box)
	# Call display, connect finished with next display.
	dialogue_box.display_text(prompt.prompt, true)
	dialogue_box.display_finished.connect(delay_timer.start.bind(0.2))
