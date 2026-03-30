extends Node3D

@export var subject_1: Node3D
@export var subject_2: Node3D
@export var subject_3: Node3D
@export var subjects := 1.0
var total_subjects := 1.0

@export var puzzle_cube: Node3D
@export var puzzle_cube_2: Node3D
@export var button: Node3D
@export var button_2: Node3D
@export var flag: Node3D

@onready var cubes: Node3D = $Cubes
@onready var interactables: Node3D = $Interactables
@onready var blocks_control: Node3D = $Blocks
#@onready var sfx: Node3D = $SFX


@onready var fade_anim: AnimationPlayer = $FadeAnim

var can_start = false
var can_reset = false

@export var time = 20
@onready var time_limit: Control = $TimeLimit

var invalid = 0
var blocks = 0
var can_grab = false
var grabbing = false
var block_position := Vector3(0, 0, 0)
var cursor_position := Vector3(0, 0, 0)

@onready var level_ui: Control = $LevelUI
@export var next := 0
var active = false

@export var MainTheme : Node3D


func _ready() -> void:
	#time_limit.time = time 
	#time_limit.time_set()
	total_subjects = subjects

func begin():
	#Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#fade_anim.play("FadeIn")
	if subject_1:
		subject_1.begin()
	if subject_2:
		subject_2.begin()
	if subject_3:
		subject_3.begin()
	for b in blocks_control.get_children():
		b.begin()
	for c in cubes.get_children():
		c.begin()
	for i in interactables.get_children():
		i.begin()
	active = true
	total_subjects = subjects
	await get_tree().create_timer(2.5, false).timeout
	#Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	level_ui.begin()
	can_start = true
	get_tree().current_scene.stop()


func goal():
	total_subjects -= 1
	if total_subjects > 0:
		return
	can_reset = false
	time_limit.stop()
	#Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if subject_1:
		subject_1.end()
	if subject_2:
		subject_2.end()
	if subject_3:
		subject_3.end()
	if flag:
		flag.goal_sound()
	level_ui.goal()
	get_tree().current_scene.disable_pause()
	await get_tree().create_timer(0.5, false).timeout
	for b in blocks_control.get_children():
		b.goal()
	for c in cubes.get_children():
		c.goal()
	for i in interactables.get_children():
		i.goal()
	await get_tree().create_timer(3.0, false).timeout
	MainTheme.stop()
	#fade_anim.play("FadeOut")
	hide()
	await get_tree().create_timer(0.1, false).timeout
	await get_tree().process_frame
	get_tree().current_scene.next_level(next)
	#get_tree().change_scene_to_file(next_level)

func false_start():
	#Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#fade_anim.play("FadeIn")
	if subject_1:
		subject_1.begin()
	if subject_2:
		subject_2.begin()
	if subject_3:
		subject_3.begin()
	for b in blocks_control.get_children():
		b.begin()
	for c in cubes.get_children():
		c.begin()
	for i in interactables.get_children():
		i.begin()
	#active = true
	await get_tree().create_timer(2.5, false).timeout
	if subject_1:
		subject_1.goal()
	if subject_2:
		subject_2.goal()
	if subject_3:
		subject_3.goal()
	level_ui.goal()
	for b in blocks_control.get_children():
		b.goal()
	for c in cubes.get_children():
		c.goal()
	for i in interactables.get_children():
		i.goal()
	#await get_tree().create_timer(2.0, false).timeout
	#hide()
	#subject_1.global_position.y = 0.0
	#fade_anim.play("FadeOut")


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
	MainTheme.stop()
	get_tree().change_scene_to_file("res://Levels/Level" + l + ".tscn")

##resets walls
func restart(t):
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
	for b in blocks_control.get_children():
		b.reset()
	total_subjects = subjects
	#for c in cubes.get_children():
		#c.goal()
	#for i in interactables.get_children():
		#i.reset()
	#await get_tree().create_timer(3.0, false).timeout
	#fade_anim.play("FadeOut")
	#await get_tree().create_timer(0.1, false).timeout
	#await get_tree().process_frame
	MainTheme.stop()
	#Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	#cursor_coll.set_deferred("disabled", false)
	await get_tree().create_timer(0.5, false).timeout
	if t == true:
		get_tree().current_scene.stop()
		can_start = true
	else:
		level_ui.goal()
	#get_tree().change_scene_to_file(get_tree().current_scene.scene_file_path)

func restart_overworld():
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
	total_subjects = subjects
	#for c in cubes.get_children():
		#c.goal()
	#for i in interactables.get_children():
		#i.reset()
	#await get_tree().create_timer(3.0, false).timeout
	#fade_anim.play("FadeOut")
	#await get_tree().create_timer(0.1, false).timeout
	#await get_tree().process_frame
	MainTheme.stop()
	#Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	#cursor_coll.set_deferred("disabled", false)
	await get_tree().create_timer(0.5, false).timeout
	level_ui.goal()

##doesn't reset walls
func reset():
	if can_reset == false:
		return
	can_reset = false
	total_subjects = subjects
	time_limit.reset()
	MainTheme.stop()
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
	#Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().current_scene.stop()
	#cursor_coll.set_deferred("disabled", false)
	await get_tree().create_timer(0.5, false).timeout
	can_start = true


func level_select():
	if subject_1:
		subject_1.end()
	if subject_2:
		subject_2.end()
	if subject_3:
		subject_3.end()
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
	MainTheme.stop()
	#get_tree().change_scene_to_file("res://Levels/LevelSelect.tscn")
	get_tree().current_scene.overworld_return()


#func _physics_process(_delta: float) -> void:
	#if active == false:
		#return
	#var cam := $Camera3D
	#var mousePos := get_viewport().get_mouse_position()
	#
	#var rayStart: Vector3 = cam.project_ray_origin(mousePos)
	#var direction: Vector3 = cam.project_ray_normal(mousePos)
	#
	#var plane := Plane(Vector3.UP)
	#
	#var intersection = plane.intersects_ray(rayStart, direction)
	#
	#if intersection:
		#cursor.global_position.x = intersection.x
		#cursor.global_position.z = intersection.z
	#
	#
	#if grabbing == true:
		#current_block.global_position = round(cursor.global_position + (block_position - cursor_position)) 
#
#func block_move(p):
	#current_block.global_position = p

func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("grab") and can_grab == true and grabbing == false:
		#block_position = current_block.global_position
		#cursor_position = cursor.global_position
		#cursor_area.position.y -= 5
		#blocks = 0
		#current_block.grab()
		#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		#can_grab = false
		#grabbing = true
	#elif event.is_action_pressed("grab") and grabbing == true and invalid <= 0:
		#grabbing = false
		#cursor_area.position.y += 5
		#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		#current_block.release()
	#elif event.is_action_pressed("rotate") and grabbing == true:
		#current_block.get_rotated()
	#elif event.is_action_pressed("restart"):
		#reset()
		#level_ui.release()
	if active == false:
		return
	if event.is_action_pressed("start"):
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
	#elif event.is_action_pressed("fullscreen"):
		#if get_window().mode == Window.MODE_FULLSCREEN:
			#get_window().set_mode(Window.MODE_WINDOWED)
		#else:
			#get_window().set_mode(Window.MODE_FULLSCREEN)

func start():
	if can_start == false:
		return
	can_start = false
	can_reset = true
	time_limit.start()
	MainTheme.start()
	get_tree().current_scene.start()
	if subject_1:
		subject_1.start()
	if subject_2:
		subject_2.start()
	if subject_3:
		subject_3.start()
	if puzzle_cube:
		puzzle_cube.start()
	if puzzle_cube_2:
		puzzle_cube_2.start()

#func unpause():
	#if can_reset == true:
		#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


func speedx1():
	if puzzle_cube:
		puzzle_cube.speedx1()
	if puzzle_cube_2:
		puzzle_cube_2.speedx1()

func speedx2():
	if puzzle_cube:
		puzzle_cube.speedx2()
	if puzzle_cube_2:
		puzzle_cube_2.speedx2()

func speedx3():
	if puzzle_cube:
		puzzle_cube.speedx3()
	if puzzle_cube_2:
		puzzle_cube_2.speedx3()



func _on_death_plane_body_entered(body: Node3D) -> void:
	if active == false:
		return
	if body.is_in_group("subject"):
		body.fall()
	elif body.is_in_group("cube"):
		body.fall()
