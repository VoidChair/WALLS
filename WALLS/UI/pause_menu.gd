extends Control



@onready var resume: TextureRect = $Resume
@onready var quit: TextureRect = $Quit
@onready var level_select: TextureRect = $LevelSelect
@onready var restart: TextureRect = $Restart


@onready var resume_button: Button = $ResumeButton
@onready var level_select_button: Button = $LevelSelectButton
@onready var restart_button: Button = $RestartButton
@onready var quit_button: Button = $QuitButton



@onready var master_slider: HSlider = $MasterSlider
@onready var music_slider: HSlider = $MusicSlider
@onready var sfx_slider: HSlider = $SFXSlider

#@onready var full_screen_check: CheckBox = $PauseMenu/FullScreenCheck

@onready var master_bus = AudioServer.get_bus_index("Master")
@onready var music_bus = AudioServer.get_bus_index("Music")
@onready var sfx_bus = AudioServer.get_bus_index("SFX")

@export var music: Node3D
var level: Node3D

var paused = false
var control_type = 1
var controls = true
var can_pause = false


#func _ready() -> void:
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if can_pause == false:
		return
	if event.is_action_pressed("pause"):
		if paused == false:
			pause()
		else:
			unpause()
	#if event.is_action_pressed("fullscreen"):
		#fullscreen()
	#if event.is_action_pressed("controls"):
		#hide_controls()
	#if event is InputEventKey or event is InputEventMouseMotion or event is InputEventMouseButton:
		#if control_type != 1:
			#control_type = 1
			#if paused == true:
				#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	#if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		#if control_type != 2:
			#control_type = 2
			#if paused == true:
				#resume_button.grab_focus()
		
	
	#if event.is_action_pressed("fullscreen"):
		#fullscreen()

func pause():
	paused = true
	if control_type == 1:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if control_type == 2:
		restart_button.grab_focus()
	show()
	music.deafen()
	get_tree().paused = true

func unpause():
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#get_tree().current_scene.unpause()
	paused = false
	hide()
	music.undeafen()
	get_tree().paused = false


func _on_quit_button_pressed() -> void:
	#return
	get_tree().quit()


func _on_master_slider_value_changed(value):
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(value))
	AudioServer.set_bus_mute(master_bus, value < 0.05)


func _on_music_slider_value_changed(value):
	AudioServer.set_bus_volume_db(music_bus, linear_to_db(value))
	AudioServer.set_bus_mute(music_bus, value < 0.05)


func _on_sfx_slider_value_changed(value):
	AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(value))
	AudioServer.set_bus_mute(sfx_bus, value < 0.05)

#func _on_full_screen_check_toggled(toggled_on):
	#if toggled_on:
		#get_window().set_mode(Window.MODE_FULLSCREEN)
	#else:
		#get_window().set_mode(Window.MODE_WINDOWED)
#
func fullscreen():
	if get_window().mode == Window.MODE_FULLSCREEN:
		get_window().set_mode(Window.MODE_WINDOWED)
		#full_screen_check.button_pressed = false
	else:
		get_window().set_mode(Window.MODE_FULLSCREEN)
		#full_screen_check.button_pressed = true





func _on_resume_button_focus_entered() -> void:
	resume.show()


func _on_resume_button_focus_exited() -> void:
	resume.hide()


func _on_resume_button_mouse_entered() -> void:
	resume.show()


func _on_resume_button_mouse_exited() -> void:
	resume.hide()


func _on_quit_button_focus_entered() -> void:
	quit.show()


func _on_quit_button_focus_exited() -> void:
	quit.hide()


func _on_quit_button_mouse_entered() -> void:
	quit.show()


func _on_quit_button_mouse_exited() -> void:
	quit.hide()



func _on_restart_button_focus_entered() -> void:
	restart.show()


func _on_restart_button_focus_exited() -> void:
	restart.hide()


func _on_restart_button_mouse_entered() -> void:
	restart.show()


func _on_restart_button_mouse_exited() -> void:
	restart.hide()


func _on_restart_button_pressed() -> void:
	unpause()
	get_tree().current_scene.restart()



func _on_resume_button_pressed() -> void:
	unpause()


func _on_level_select_button_pressed() -> void:
	unpause()
	get_tree().current_scene.level_select()


func _on_level_select_button_focus_entered() -> void:
	level_select.show()


func _on_level_select_button_focus_exited() -> void:
	level_select.hide()


func _on_level_select_button_mouse_entered() -> void:
	level_select.show()


func _on_level_select_button_mouse_exited() -> void:
	level_select.hide()
