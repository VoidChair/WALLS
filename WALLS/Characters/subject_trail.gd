extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	animation_player.play("fade")

func disappear():
	animation_player.play("disappear")

func pause():
	animation_player.pause()
