extends Node3D

@onready var sfx: AudioStreamPlayer = $SFX
@onready var anim: AnimationPlayer = $AnimationPlayer
var delay := 0.05


func _ready() -> void:
	anim.play("hidden")
	delay = (abs(global_position.x) + global_position.z) * 0.03
	sfx.volume_db = randf_range(-15.0, -10.0)
	sfx.pitch_scale = 0.86
	await get_tree().create_timer(delay, false).timeout
	anim.play("start")

func goal():
	sfx.pitch_scale = 0.76
	await get_tree().create_timer((delay * -1) + 2.0, false).timeout
	anim.play_backwards("start")
