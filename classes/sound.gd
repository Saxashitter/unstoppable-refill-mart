extends AudioStreamPlayer2D
class_name ExtendedSound

@export var pitch_range_min: float = 0.5
@export var pitch_range_max: float = 1.5

func play_pitch_rng():
	play(0)
	pitch_scale = lerp(pitch_range_min, pitch_range_max, randf())
