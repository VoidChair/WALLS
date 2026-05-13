extends Node3D

@onready var anim: AnimationPlayer = $AnimationPlayer
var activated = false

func begin():
	anim.play("hidden")
	activated = false

func activate():
	if activated == true:
		return
	anim.play("show")
	activated = true

func goal():
	if activated == true:
		anim.play("hide")
		activated = false
