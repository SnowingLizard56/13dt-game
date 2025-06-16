extends Control

@export_file("*.txt") var file_path: String = "res://Assets/Dialogue/TestDialogue.txt"
@export var dialogue_box_scene: PackedScene
@export var delay_timer: Timer
var content_array: PackedStringArray
var content_index: int
var choice_return_indices: PackedInt32Array


func _ready() -> void:
	run_text(file_path)


func read_file(fp: String) -> PackedStringArray:
	# Load file
	var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	# Convert to string
	var content_string: String = file.get_as_text()
	var content: PackedStringArray = file.get_as_text().split("<>")
	# Replace random
	var idx: int = 0
	while idx < len(content):
		# Select items for {}
		# Setup replacement
		var replacement_string: String = ""
		# Define the thing we're searching
		var searching_string = content[idx].strip_edges()
		while true:
			# Find open
			var start: int = searching_string.find("{")
			# If no open, done.
			if start == -1:
				replacement_string += searching_string
				break
			# Add everything to the left of the { to replacement
			replacement_string += searching_string.left(start)
			# End
			var end: int = searching_string.find("}", start)
			# Define substring
			var substring: String = searching_string.substr(start+1, end-start-1)
			# Choose slice of substring at random. Strip whitespace, newlines.
			replacement_string += substring.get_slice("|", randi_range(0, substring.get_slice_count("|")-1)).strip_edges()
			# Now searching everything to the right of }
			searching_string = searching_string.right(-end-1)
		# Strip \r
		# Set
		content.set(idx, replacement_string)
		idx += 1
	return content


func run_text(fp: String) -> void:
	# Reset index
	content_index = -1
	# Load strings
	content_array = read_file(fp)
	# Display first
	next_content()


func next_content() -> void:
	content_index += 1
	# Finish content_array
	if content_index == len(content_array):
		return
	# If its a number, wait that long.
	if Global.num_regex.search(content_array[content_index]):
		delay_timer.wait_time = float(content_array[content_index])
		delay_timer.start()
		return
	# Choices
	if content_array[content_index].begins_with(">"):
		var option_count: int = int(content_array[content_index].right(-1))
	# Flat text. Instantiate and add
	var dialogue_box: DialogueBox = dialogue_box_scene.instantiate()
	get_node("VBoxContainer").add_child(dialogue_box)
	# Call display, connect finished with next display.
	dialogue_box.display_text(content_array[content_index], false)
	dialogue_box.display_finished.connect(next_content)
