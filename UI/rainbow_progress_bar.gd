extends TextureProgressBar

const SPEED := 0.5
const FADE_TIME := 0.1
const SHRINK_TIME := 0.5


func _process(delta: float) -> void:
	var texture: GradientTexture2D = texture_progress
	texture.fill_from.x += SPEED * delta
	texture.fill_to.x = texture.fill_from.x + 1.0


func _ready() -> void:
	Global.level_up.connect(_on_level_up)


func _on_level_up() -> void:
	modulate.a = 0.0
	value = 1.0
	show()
	var t := get_tree().create_tween()
	t.set_ignore_time_scale()
	t.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	t.tween_property(self, "modulate", Color.WHITE, FADE_TIME)


func _on_component_control_continue_pressed() -> void:
	get_parent().value = 0.0
	var t := get_tree().create_tween()
	t.set_ignore_time_scale()
	t.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	t.tween_property(self, "value", 0.0, SHRINK_TIME)
	t.tween_callback(hide)
