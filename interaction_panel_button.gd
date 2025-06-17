extends Button

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _on_mouse_entered():
	if !button_pressed:
		size_flags_horizontal = Control.SIZE_SHRINK_CENTER

func _on_mouse_exited():
	if !button_pressed:
		size_flags_horizontal = Control.SIZE_SHRINK_END

func _process(delta: float) -> void:
	if button_pressed:
		size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
