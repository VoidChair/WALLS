extends StaticBody3D

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var coll: CollisionShape3D = $CollisionShape3D
@onready var empty: Node3D = $Empty
@onready var bridge: Node3D = $Bridge
var delay := 0.05
@export var activated = false
@export var target: Node3D

func _ready() -> void:
	anim.play("hidden")

func begin():
	if activated == false:
		empty.show()
		bridge.hide()
		coll.set_deferred("disabled", true)
	else:
		empty.hide()
		bridge.show()
		coll.set_deferred("disabled", false)
	delay = (abs(global_position.x) + global_position.z) * 0.04
	await get_tree().create_timer(delay, false).timeout
	anim.play("start")


func activate():
	if target:
		target.activate()
	empty.hide()
	bridge.show()
	coll.set_deferred("disabled", false)

func deactivate():
	if target:
		target.deactivate()
	empty.show()
	bridge.hide()
	coll.set_deferred("disabled", true)

func goal():
	await get_tree().create_timer((delay * -1) + 2.0, false).timeout
	anim.play("goal")

func reset():
	if target:
		target.reset()
	empty.show()
	bridge.hide()
	coll.set_deferred("disabled", true)
