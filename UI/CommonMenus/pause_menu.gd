class_name PauseMenu extends Control

var main_menu_button_pressed_once: bool = false
@onready var dimmer: ColorRect = $DimBG
@onready var resume_button: Button = $Container/Resume
@onready var options_button: Button = $Container/Options
@onready var main_menu_button: Button = $Container/MainMenu

var paused: bool = false
var return_focus_target: Control


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		return_focus_target = get_viewport().gui_get_focus_owner()
		if paused:
			_on_resume_pressed()
		elif not get_tree().paused:
			start()
		paused = not paused


func start():
	main_menu_button_pressed_once = false
	main_menu_button.text = "Main Menu"
	
	show()
	modulate.a = 1.0
	resume_button.modulate.a = 0.0
	options_button.modulate.a = 0.0
	main_menu_button.modulate.a = 0.0
	dimmer.modulate.a = 0.0
	get_tree().paused = true
	
	resume_button.grab_focus()
	
	var t := get_tree().create_tween()
	t.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	t.tween_property(dimmer, "modulate", Color.WHITE, 0.3)
	t.tween_property(resume_button, "modulate", Color.WHITE, 0.3)
	t.parallel().tween_property(options_button, "modulate", Color.WHITE, 0.3)
	t.parallel().tween_property(main_menu_button, "modulate", Color.WHITE, 0.3)


func _on_main_menu_pressed() -> void:
	if !main_menu_button_pressed_once:
		main_menu_button_pressed_once = true
		main_menu_button.text = "Abandon Run?"
		return
	var t := get_tree().create_tween()
	t.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	Global.root.cover.modulate.a = 0.0
	Global.root.cover.show()
	t.tween_property(Global.root.cover, "modulate", Color.WHITE, 0.2)
	t.tween_callback(get_tree().set.bind(&"paused", false))
	t.tween_callback(Global.switch_scene.bind(Global.MAIN_MENU_SCENE))


func _on_options_pressed() -> void:
	pass # Replace with function body.


func _on_resume_pressed() -> void:
	Engine.time_scale = 0.0
	var t := get_tree().create_tween()
	t.set_ignore_time_scale()
	t.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	t.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.3)
	t.tween_callback(get_tree().set.bind(&"paused", false))
	t.tween_callback(hide)
	if return_focus_target:
		t.tween_callback(return_focus_target.grab_focus)
	t.tween_property(Engine, "time_scale", 1.0, 1.0)
