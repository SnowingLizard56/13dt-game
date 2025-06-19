extends Control

var stored_content: Dialogue
## Characters per frame
@export var character_speed: int = 1
var sentence_queue: Array[Sentence]
var current_sentence: Sentence
var sentence_fully_displayed: bool = false

@onready var label: RichTextLabel = $PanelContainer/RichTextLabel

signal finish_sequence


func _ready() -> void:
	display_dialogue(preload("res://Assets/Dialogue/TestDialogue.tres"))


func display_dialogue(content: Dialogue):
	for i in $Backgrounds.get_children():
		i.hide()
	$Backgrounds.get_child(int(content.owner)).show()
	stored_content = content
	next_content()


func next_content() -> void:
	# Reset choicecontainer children
	for i in range(1, $ChoiceContainer.get_child_count()):
		$ChoiceContainer.get_child(i).queue_free()
	# Replenish Sentence queue
	if sentence_queue.is_empty():
		# If cant, then the sequence is finished. return
		if stored_content.sentences.is_empty():
			finish_sequence.emit()
			queue_free()
			return
		# But if can, move sentence from content.sentences to sentence_queue
		sentence_queue.push_front(stored_content.sentences[0])
		stored_content.sentences.pop_front()
	
	# Operate on sentence_queue[-1]
	current_sentence = sentence_queue[-1]
	# Remove displayed sentence from queue.
	sentence_queue.pop_back()
	
	
	# Display sentence text
	label.text = current_sentence.get_text()
	label.visible_characters = 0
	sentence_fully_displayed = false
	

func dialogue_option_chosen(prompt: Prompt):
	# Add sentences to sentence queue
	prompt.sentences.reverse()
	sentence_queue.append_array(prompt.sentences)
	next_content()


func _process(delta: float) -> void: 
	if !current_sentence:
		return
	if label.visible_characters >= label.get_total_character_count():
		if !sentence_fully_displayed:
			if len(current_sentence.choices) > 0:
				# Make a button for each choice
				for prompt in current_sentence.choices:
					# Make a new button
					var b:Button = $ChoiceContainer.get_child(0).duplicate()
					b.text = prompt.prompt
					b.show()
					b.pressed.connect(dialogue_option_chosen.bind(prompt))
					$ChoiceContainer.add_child(b)
					# Focus neighbours
					if $ChoiceContainer.get_child_count() > 2:
						b.focus_neighbor_bottom = $ChoiceContainer.get_child(-2).get_path()
						$ChoiceContainer.get_child(-2).focus_neighbor_top = b.get_path()
					else:
						b.grab_focus.call_deferred()
		
		sentence_fully_displayed = true
		if len(current_sentence.choices) == 0:
			if Input.is_action_just_pressed("ui_accept"):
				next_content()
	else:
		# Continue displaying
		label.visible_characters += character_speed
		if Input.is_action_pressed("ui_accept"):
			label.visible_characters += character_speed
