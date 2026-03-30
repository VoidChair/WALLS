extends Node3D

@export var next_level: String

@export var cursor: Node3D
@export var current_block: Node3D
@export var cursor_area: Node3D

@export var subject_1: Node3D
@export var subject_2: Node3D
@export var subject_3: Node3D
@export var subjects := 1.0
var total_subjects := 1.0

@export var puzzle_cube: Node3D
@export var puzzle_cube_2: Node3D
@export var button: Node3D
@export var button_2: Node3D

@onready var cubes: Node3D = $Cubes
@onready var interactables: Node3D = $Interactables
@onready var blocks_control: Node3D = $Blocks


@onready var fade_anim: AnimationPlayer = $FadeAnim
@onready var cursor_coll: CollisionShape3D = $Cursor/CursorArea/CursorColl

var can_start = false
var can_reset = false

var invalid = 0
var blocks = 0
var can_grab = false
var grabbing = false
var block_position := Vector3(0, 0, 0)
var cursor_position := Vector3(0, 0, 0)

@onready var level_ui: Control = $LevelUI

func _ready() -> void:
	total_subjects = subjects
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	fade_anim.play("FadeIn")
	await get_tree().create_timer(2.5, false).timeout
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	can_start = true

func goal():
	total_subjects -= 1
	if total_subjects > 0:
		return
	can_reset = false
	if subject_1:
		subject_1.end()
	if subject_2:
		subject_2.end()
	await get_tree().create_timer(0.5, false).timeout
	for b in blocks_control.get_children():
		b.goal()
	for c in cubes.get_children():
		c.goal()
	for i in interactables.get_children():
		i.goal()
	await get_tree().create_timer(3.0, false).timeout
	fade_anim.play("FadeOut")
	await get_tree().create_timer(0.1, false).timeout
	await get_tree().process_frame
	get_tree().change_scene_to_file(next_level)

func level(l):
	total_subjects -= 1
	if total_subjects > 0:
		return
	can_reset = false
	if subject_1:
		subject_1.end()
	if subject_2:
		subject_2.end()
	await get_tree().create_timer(0.5, false).timeout
	for b in blocks_control.get_children():
		b.goal()
	for c in cubes.get_children():
		c.goal()
	for i in interactables.get_children():
		i.goal()
	await get_tree().create_timer(3.0, false).timeout
	fade_anim.play("FadeOut")
	await get_tree().create_timer(0.1, false).timeout
	await get_tree().process_frame
	get_tree().change_scene_to_file("res://Levels/Level" + l + ".tscn")

func restart():
	if subject_1:
		subject_1.end()
	if subject_2:
		subject_2.end()
	if subject_3:
		subject_3.goal()
	for b in blocks_control.get_children():
		b.goal()
	for c in cubes.get_children():
		c.goal()
	for i in interactables.get_children():
		i.goal()
	await get_tree().create_timer(3.0, false).timeout
	fade_anim.play("FadeOut")
	await get_tree().create_timer(0.1, false).timeout
	await get_tree().process_frame
	get_tree().change_scene_to_file(get_tree().current_scene.scene_file_path)


func _physics_process(_delta: float) -> void:
	
	var cam := $Camera3D
	var mousePos := get_viewport().get_mouse_position()
	
	var rayStart: Vector3 = cam.project_ray_origin(mousePos)
	var direction: Vector3 = cam.project_ray_normal(mousePos)
	
	var plane := Plane(Vector3.UP)
	
	var intersection = plane.intersects_ray(rayStart, direction)
	
	if intersection:
		cursor.global_position.x = intersection.x
		cursor.global_position.z = intersection.z
	
	
	if grabbing == true:
		current_block.global_position = round(cursor.global_position + (block_position - cursor_position)) 

func block_move(p):
	current_block.global_position = p

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("grab") and can_grab == true and grabbing == false:
		block_position = current_block.global_position
		cursor_position = cursor.global_position
		cursor_area.position.y -= 5
		blocks = 0
		current_block.grab()
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		can_grab = false
		grabbing = true
	elif event.is_action_pressed("grab") and grabbing == true and invalid <= 0:
		grabbing = false
		cursor_area.position.y += 5
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		current_block.release()
	elif event.is_action_pressed("rotate") and grabbing == true:
		current_block.get_rotated()
	#elif event.is_action_pressed("restart"):
		#reset()
	elif event.is_action_pressed("start"):
		if can_start == true:
			start()
			level_ui.press()
		elif can_reset == true:
			reset()
			level_ui.release()
	elif event.is_action_pressed("speedx1"):
		speedx1()
	elif event.is_action_pressed("speedx2"):
		speedx2()
	elif event.is_action_pressed("speedx3"):
		speedx3()
	elif event.is_action_pressed("fullscreen"):
		if get_window().mode == Window.MODE_FULLSCREEN:
			get_window().set_mode(Window.MODE_WINDOWED)
		else:
			get_window().set_mode(Window.MODE_FULLSCREEN)

func start():
	can_reset = true
	can_start = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	cursor_coll.set_deferred("disabled", true)
	if subject_1:
		subject_1.start()
	if subject_2:
		subject_2.start()
	if subject_3:
		subject_3.start()
	if current_block:
		current_block.unhover()
	if puzzle_cube:
		puzzle_cube.start()
	if puzzle_cube_2:
		puzzle_cube_2.start()

func unpause():
	if can_reset == true:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func speedx1():
	Engine.time_scale = 1.0
	if puzzle_cube:
		puzzle_cube.speedx1()
	if puzzle_cube_2:
		puzzle_cube_2.speedx1()

func speedx2():
	Engine.time_scale = 1.5
	if puzzle_cube:
		puzzle_cube.speedx2()
	if puzzle_cube_2:
		puzzle_cube_2.speedx2()

func speedx3():
	Engine.time_scale = 3.0
	if puzzle_cube:
		puzzle_cube.speedx3()
	if puzzle_cube_2:
		puzzle_cube_2.speedx3()

func reset():
	if can_reset == false:
		return
	can_reset = false
	total_subjects = subjects
	if subject_1:
		subject_1.reset()
	if subject_2:
		subject_2.reset()
	if subject_3:
		subject_3.reset()
	if puzzle_cube:
		puzzle_cube.reset()
	if puzzle_cube_2:
		puzzle_cube_2.reset()
	if button:
		button.reset()
	if button_2:
		button_2.reset()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	cursor_coll.set_deferred("disabled", false)
	await get_tree().create_timer(0.2, false).timeout
	can_start = true


func _on_cursor_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("block") and grabbing == false:
		blocks += 1
		can_grab = true
		if current_block != null:
			current_block.unhover()
		current_block = body
		current_block.hover()


func _on_cursor_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("block") and grabbing == false:
		blocks -= 1
		if blocks <= 0:
			current_block.unhover()
			can_grab = false


func _on_death_plane_body_entered(body: Node3D) -> void:
	if body.is_in_group("subject"):
		body.fall()
	elif body.is_in_group("cube"):
		body.fall()
