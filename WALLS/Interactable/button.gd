extends Area3D

@onready var press_anim: AnimationPlayer = $PressAnim

var cube_pressed = false

@onready var coll: CollisionShape3D = $CollisionShape3D

@export var target: Node3D

@onready var anim: AnimationPlayer = $AnimationPlayer
var delay := 0.05

@onready var click: AudioStreamPlayer = $Click
@onready var click_2: AudioStreamPlayer = $Click2
var active = false


func _ready() -> void:
	anim.play("hidden")

func begin():
	delay = (abs(global_position.x) + global_position.z) * 0.04
	await get_tree().create_timer(delay, false).timeout
	active = true
	anim.play("start")

func goal():
	active = false
	await get_tree().create_timer((delay * -1) + 2.0, false).timeout
	press_anim.play("LevelEnd")
	anim.play_backwards("start")

func activate():
	press_anim.play("CubePressed")
	click.play()
	cube_pressed = true
	target.activate()
	coll.set_deferred("disabled", true)

func reset():
	cube_pressed = false
	press_anim.play("RESET")
	target.reset()
	coll.set_deferred("disabled", false)

func _on_body_entered(body: Node3D) -> void:
	if active == false:
		return
	if body.is_in_group("subject") and cube_pressed == false:
		press_anim.play("Pressed")
		click.play()
		target.activate()
	if body.is_in_group("cube") and cube_pressed == false:
		activate()
		body.hide()
		body.place()
		body.global_position -= Vector3(0, 5, 0)


func _on_body_exited(body: Node3D) -> void:
	if active == false:
		return
	if body.is_in_group("subject") and cube_pressed == false:
		press_anim.play_backwards("Pressed")
		target.deactivate()
		click_2.play()
