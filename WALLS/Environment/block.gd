extends Node3D

@onready var anim: AnimationPlayer = $AnimationPlayer
var delay := 0.05
@onready var sfx: AudioStreamPlayer = $SFX
@export var audible = true

func _ready() -> void:
	anim.play("hidden")

func begin():
	#sfx.pitch_scale = 0.86
	#sfx.pitch_scale = randf_range(0.8, 0.9)
	#sfx.volume_db = -40.0
	delay = (abs(global_position.x) + global_position.z) * 0.04
	await get_tree().create_timer(delay, false).timeout
	anim.play("start")
	await get_tree().create_timer(0.4, false).timeout
	if audible == true:
		get_tree().current_scene.click()

func goal():
	#sfx.pitch_scale = 0.78
	#sfx.pitch_scale = randf_range(0.7, 0.8)
	await get_tree().create_timer((delay * -1) + 2.0, false).timeout
	if audible == true:
		get_tree().current_scene.click_2()
	anim.play_backwards("start")
