extends RichTextLabel

@export_file("*.txt") var file_path: String = "res://Assets/Dialogue/TestDialogue.txt"
var content_array: PackedStringArray


func _ready() -> void:
	for i in read_file(file_path):
		text += i + "\n\n"
	visible_characters = 0


func _process(delta: float) -> void:
	visible_characters += 1


func read_file(fp: String) -> PackedStringArray:
	# Load file
	var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	# Convert to string
	var content: PackedStringArray = file.get_as_text().split("\r\n\r\n")
	var idx: int = 0
	while idx < len(content):
		# Select items for {}
		# Setup replacement
		var replacement_string: String = ""
		# Define the thing we're searching
		var searching_string = content[idx]
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
