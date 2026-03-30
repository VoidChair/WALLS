extends Node3D

var save_file_path = "user://save"
var save_file_name = "/SaveData.tres"
var saveData = SaveData.new()

@onready var levels: Node3D = $Levels
@onready var title_screen: Node3D = $Levels/TitleScreen
@onready var test_level: Node3D = $TestLevel
@onready var overworld: Node3D = $Levels/LevelSelect
@onready var end_screen: Node3D = $Levels/EndScreen
var current_level : Node3D
var level_number := 0
@onready var camera_3d: Camera3D = $Camera3D
@onready var cursor: Node3D = $Cursor
@onready var cursor_area: Area3D = $Cursor/CursorArea
@onready var MainTheme: Node3D = $MainTheme
@onready var blackness: ColorRect = $Blackness
@onready var master_bus = AudioServer.get_bus_index("Master")
@onready var pause_menu: Control = $PauseMenu
var current_block: Node3D
var invalid = 0
var blocks = 0
var can_grab = false
var grabbing = false
var block_position := Vector3(0, 0, 0)
var cursor_position := Vector3(0, 0, 0)
var started = false

@onready var click_sfx: AudioStreamPlayer = $SFX

func verify_save_directory(path: String):
	DirAccess.make_dir_absolute(path)

func load_data():
	saveData = ResourceLoader.load(save_file_path + save_file_name)

func save():
	ResourceSaver.save(saveData, save_file_path + save_file_name)

func _ready() -> void:
	speedx3()
	verify_save_directory(save_file_path)
	if ResourceLoader.exists(save_file_path + save_file_name):
		load_data()
	else:
		save()
	#AudioServer.set_bus_mute(master_bus, true)
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)
	AudioServer.set_bus_volume_db(master_bus, -70.0)
	current_level = title_screen
	current_level.false_start()
	test_level.false_start()
	test_level.show()
	MainTheme.false_start()
	cursor.position.y = -10
	await get_tree().create_timer(5.0, false).timeout
	speedx1()
	test_level.hide()
	test_level.position.y = -50
	current_level.begin()
	current_level.show()
	blackness.hide()
	#AudioServer.set_bus_mute(master_bus, false)
	AudioServer.set_bus_volume_db(master_bus, 0.0)
	current_level.begin()
	MainTheme.begin()
	await get_tree().create_timer(2.5, false).timeout
	pause_menu.can_pause = true
	cursor.position.y = 0

func click():
	click_sfx.pitch_scale = randf_range(0.8, 0.9)
	click_sfx.play()

func click_2():
	click_sfx.pitch_scale = randf_range(0.7, 0.8)
	click_sfx.play()


func next_level(l):
	current_level.hide()
	current_level.active = false
	if l == 0:
		current_level.restart(false)
		current_level.position.y = -50.0
		current_level = overworld
		if level_number != 0:
			saveData.levels[level_number] = 2
			if saveData.levels[level_number + 1] != 2 and level_number <= 16:
				saveData.levels[level_number + 1] = 1
			save()
	#if l > 1 and l < 16:
		#saveData.levels[l - 1] = 2
		#if saveData.levels[l] != 2:
			#saveData.levels[l] = 1
		#save()
	#elif l == 16: 
		#saveData.levels[l - 1] = 2
		#l = 0
		#save()
	elif current_level == overworld:
		current_level.restart_overworld()
		current_level.position.y = -50.0
		current_level = levels.get_child(l)
		level_number = l
	else:
		current_level.restart(false)
		current_level.position.y = -50.0
		current_level = levels.get_child(l)
		level_number = l
	if l == 17:
		saveData.levels[16] = 2
		save()
	current_level.position.y = 0.0
	current_level.begin()
	current_level.show()
	await get_tree().create_timer(2.5, false).timeout
	pause_menu.can_pause = true

func overworld_return():
	current_level.hide()
	current_level.active = false
	current_level.restart(false)
	current_level.position.y = -50.0
	current_level = overworld
	level_number = 0
	current_level.position.y = 0.0
	current_level.begin()
	current_level.show()
	await get_tree().create_timer(2.5, false).timeout
	pause_menu.can_pause = true

func goal():
	current_level.goal()

func disable_pause():
	pause_menu.can_pause = false

func level_select():
	if current_level == overworld:
		return
	current_level.level_select()
	pause_menu.can_pause = false

func start():
	can_grab = false
	cursor.position.y = -10
	if current_block:
		current_block.unhover()

func stop():
	#can_grab = true
	cursor.position.y = 0

func restart():
	current_level.restart(true)

func contemplate():
	MainTheme.contemplate()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("grab") and can_grab == true and grabbing == false and current_block:
		block_position = current_block.global_position
		cursor_position = cursor.global_position
		cursor_area.position.y -= 5
		blocks = 0
		current_block.grab()
		current_level.can_start = false
		#Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		can_grab = false
		grabbing = true
	elif event.is_action_pressed("grab") and grabbing == true and invalid <= 0:
		grabbing = false
		cursor_area.position.y += 5
		current_level.can_start = true
		#Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		current_block.release()
	elif event.is_action_pressed("rotate") and grabbing == true:
		current_block.get_rotated()
	elif event.is_action_pressed("fullscreen"):
		if get_window().mode == Window.MODE_FULLSCREEN:
			get_window().set_mode(Window.MODE_WINDOWED)
		else:
			get_window().set_mode(Window.MODE_FULLSCREEN)
	elif event.is_action("speedx1"):
		speedx1()
	elif event.is_action("speedx2"):
		speedx2()
	elif event.is_action("speedx3"):
		speedx3()

func speedx1():
	Engine.time_scale = 1.0

func speedx2():
	Engine.time_scale = 1.5

func speedx3():
	Engine.time_scale = 2.0

func _physics_process(_delta: float) -> void:
	#print(saveData.levels[1])
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
