extends Node

const DIFFICULTY_XP_SETTINGS: PackedFloat32Array = [
	40., 100., 400.,
	70., 100., 700.,
	100., 100., 1000.,
	30., 2., 60.,
	9999., 1., 9999.]
enum Difficulty {
	CHALLENGING = 0,
	DIFFICULT = 1,
	HARD = 2,
	UNFORGIVING = 3,
	VERY_DIFFICULT = 4
}
var difficulty := Difficulty.HARD


func spawn_enemies_mid() -> bool:
	return difficulty > Difficulty.HARD


func calculate_xp_cutoff() -> float:
	var minimum = DIFFICULTY_XP_SETTINGS[3 * difficulty]
	var point_x = DIFFICULTY_XP_SETTINGS[3 * difficulty + 1]
	var point_y = DIFFICULTY_XP_SETTINGS[3 * difficulty + 2]
	return (point_y - minimum) / point_x * Global.player_level + minimum
