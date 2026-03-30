extends Area3D

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var goal_sfx: AudioStreamPlayer = $GoalSFX
@onready var goal_sfx_2: AudioStreamPlayer = $GoalSFX2
var active = false
var delay := 0.05

func _ready() -> void:
	anim.play("hidden")

func begin():
	delay = (abs(global_position.x) + global_position.z) * 0.04
	await get_tree().create_timer(delay, false).timeout
	active = true
	anim.play("start")

func goal():
	#await get_tree().create_timer(0.5, false).timeout
	active = false
	anim.play_backwards("start")


func goal_sound():
	goal_sfx.play()

func goal_one():
	pass

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("subject") and active == true:
		body.goal()
		goal_sfx_2.play()
		get_tree().current_scene.goal()
