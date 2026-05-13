extends Node2D

var mouse_speed := 800.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var left_stick_vector = Input.get_vector("stick_left", "stick_right", "stick_up", "stick_down")
	
	get_viewport().warp_mouse(round(get_global_mouse_position() + left_stick_vector * mouse_speed * delta))
