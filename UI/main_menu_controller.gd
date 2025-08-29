extends Control

const BG_COLOUR: Color = Color(0.059, 0.106, 0.149, 1.0)
const SOLID_COLOUR: Color = Color(0.961, 0.91, 0.82, 1.0)
const PLAYER_COLOUR: Color = Color(0.125, 0.647, 0.651, 1.0)
const ENEMY_COLOUR: Color = Color(0.867, 0.337, 0.224, 1.0)
const PLAYER_ROTATION_SPEED: float = 0.8
const PLAYER_ORBIT_SPEED: float = TAU / 13
const PLANET_RADIUS: float = 200.0
const SCREEN_CENTRE: Vector2 = Vector2(576, 324)
const GAME_FILE_PATH: String = "res://Actors/Game/game.tscn"

@onready var planet: Control = $Background/Planet
@onready var distant: Node2D = $Background/Distant
@onready var player: Control = $Background/Orbit/Player
@onready var orbit: Control = $Background/Orbit
@onready var splash: Control = $Splash
@onready var symbol: Control = $Splash/Symbol
@onready var symbol_cover: Control = $Splash/SymbolCover
@onready var fg: Control = $Foreground
@onready var title: Label = $Foreground/Title
@onready var exit_button: CustomButton = $Foreground/Exit
@onready var play_button: CustomButton = $Foreground/Play
@onready var options_button: CustomButton = $Foreground/Options
@onready var fade: ColorRect = $Fade
@onready var loading_screen: Control = $LoadingScreen
@onready var e127: Node2D = $LoadingScreen/E127
@onready var bg_seed: int = randi()

var symbol_lambda: float = 1.0
var splash_tween: Tween
var game_started: bool = false


signal game_scene_loaded


func _ready() -> void:
	orbit.rotation = randf() * TAU
	symbol_lambda = 1.0
	symbol_cover.modulate.a = 0
	fg.modulate.a = 0
	fg.hide()
	symbol.modulate.a = 0
	splash.show()
	splash_tween = get_tree().create_tween()
	splash_tween.tween_property(symbol, "modulate", Color.WHITE, 0.5)
	splash_tween.tween_property(self, "symbol_lambda", 2.0, 2.0).set_ease(Tween.EASE_IN_OUT)\
		.set_trans(Tween.TRANS_SINE)
	splash_tween.tween_interval(1.0)
	splash_tween.tween_property(symbol_cover, "modulate", Color.WHITE, 1.0)\
		.set_trans(Tween.TRANS_QUINT)
	splash_tween.tween_callback(symbol.hide)
	splash_tween.tween_property(splash.get_child(0), "modulate", Color(1.0, 1.0, 1.0, 0.0), 1.0)\
		.set_trans(Tween.TRANS_CUBIC)
	splash_tween.tween_callback(symbol_cover.hide)
	splash_tween.tween_callback(splash.hide)
	splash_tween.tween_callback(fg.show)
	splash_tween.tween_callback(play_button.grab_focus)
	splash_tween.tween_property(fg, "modulate", Color.WHITE, 1.0)
	play_button.grab_focus()


func skip_splash():
	return
	if splash_tween:
		splash_tween.kill()
	
	symbol.hide()
	symbol_cover.hide()
	fg.modulate.a = 1.0
	symbol_lambda = 2.0
	splash.modulate.a = 0.0


func _process(delta: float) -> void:
	if splash_tween.is_running() and Input.is_action_just_pressed("skip_splash_screen"):
		skip_splash()
	player.rotation += delta * PLAYER_ROTATION_SPEED
	orbit.rotation += delta * PLAYER_ORBIT_SPEED
	symbol.queue_redraw()
	if get_load_threaded_progress(GAME_FILE_PATH) == 1.0:
		game_scene_loaded.emit()
	distant.queue_redraw()


func _on_distant_draw() -> void:
	seed(bg_seed)
	distant.draw_rect(Rect2(-576, -324, 1152, 648), BG_COLOUR)
	for i in 256:
		var vrect: Rect2 = get_viewport_rect()
		var pos: Vector2 = vrect.size * Vector2(randf(), randf()) - vrect.size / 2
		distant.draw_circle(pos, 1.0 / distant.scale.x, Color.WHITE)
	distant.draw_rect(Rect2(-72, -40, 144, 81), BG_COLOUR)
	randomize()


func _on_player_draw() -> void:
	player.draw_rect(
		Rect2(-5, -5, 10, 10),
		PLAYER_COLOUR
	)


func _on_planet_draw() -> void:
	planet.draw_circle(Vector2.ZERO, PLANET_RADIUS, SOLID_COLOUR)


func _on_symbol_draw() -> void:
	const WIDTH := 2.0
	const RADIUS := PLANET_RADIUS - WIDTH
	const ROTATION := -TAU / 4
	const SYMBOL_N: int = 83
	
	symbol.draw_circle(Vector2.ZERO, RADIUS, SOLID_COLOUR, false, WIDTH)
	
	if symbol_lambda == 1.0:
		return
	
	var points: PackedVector2Array = []
	points.resize(SYMBOL_N * 2)
	for i in SYMBOL_N:
		var angle: float = TAU * i / SYMBOL_N
		points[2 * i] = Vector2.from_angle(angle + ROTATION) * RADIUS
		points[2 * i + 1] = Vector2.from_angle(angle * symbol_lambda + ROTATION) * RADIUS
		symbol.draw_multiline(points, SOLID_COLOUR, WIDTH)


func _on_symbol_cover_draw() -> void:
	symbol_cover.draw_circle(Vector2.ZERO, PLANET_RADIUS, SOLID_COLOUR)


func _on_exit_pressed() -> void:
	var t: Tween = get_tree().create_tween()
	fade.show()
	fade.modulate.a = 0.0
	t.tween_property(fade, "modulate", Color.WHITE, 0.3)
	t.tween_interval(0.3)
	t.tween_callback(get_tree().quit)


func _on_play_pressed() -> void:
	const MENU_ELEMENT_FADE_TIME := 0.25
	const PLANET_ZOOMOUT_TIME := 1.5
	const ORBITALS_ZOOMIN_TIME := 2.0
	
	play_button.release_focus()
	loading_screen.show()
	e127.scale = Vector2.ONE * 8
	var t: Tween = get_tree().create_tween()
	t.tween_property(exit_button, "modulate", Color(1.0, 1.0, 1.0, 0.0), MENU_ELEMENT_FADE_TIME)
	t.tween_property(play_button, "modulate", Color(1.0, 1.0, 1.0, 0.0), MENU_ELEMENT_FADE_TIME)
	t.tween_property(options_button, "modulate", Color(1.0, 1.0, 1.0, 0.0), MENU_ELEMENT_FADE_TIME)
	t.tween_property(title, "modulate", Color(1.0, 1.0, 1.0, 0.0), MENU_ELEMENT_FADE_TIME)
	t.tween_property(orbit, "scale", Vector2.ONE, PLANET_ZOOMOUT_TIME)\
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	t.parallel().tween_property(planet, "scale", Vector2.ZERO, PLANET_ZOOMOUT_TIME)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	t.tween_property(e127, "scale", Vector2.ONE, ORBITALS_ZOOMIN_TIME)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	t.tween_callback(play_animation_finished)
	
	ResourceLoader.load_threaded_request(GAME_FILE_PATH)
	game_started = true


func play_animation_finished():
	const SHIFT_TIME := 3.0
	if !get_load_threaded_progress(GAME_FILE_PATH) == 1.0:
		await game_scene_loaded
	if len(LevelGenerator.levels_ready) == 0:
		await LevelGenerator.level_generated
	
	# mini animation, scene switch
	var t: Tween = get_tree().create_tween()
	t.tween_interval(0.5)
	t.tween_property(e127, "scale", Vector2.ONE * 8, SHIFT_TIME * 0.1)\
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	t.tween_property(distant, "scale", Vector2.ONE * 8, SHIFT_TIME * 0.9)\
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	t.tween_callback(scene_switch)


func get_load_threaded_progress(path: String) -> float:
	var progress: Array = []
	ResourceLoader.load_threaded_get_status(path, progress)
	return progress[0]


func scene_switch():
	Global.switch_scene(ResourceLoader.load_threaded_get(GAME_FILE_PATH))
	
