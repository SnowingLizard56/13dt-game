extends TextureProgressBar

const SPEED := 0.5


func _process(delta: float) -> void:
	var texture: GradientTexture2D = texture_progress
	texture.fill_from.x += SPEED * delta
	texture.fill_to.x = texture.fill_from.x + 1.0


func _ready() -> void:
	Global.level_up.connect(_on_level_up)


func _on_level_up() -> void:
	show()


func _on_component_control_continue_pressed() -> void:
	hide()
