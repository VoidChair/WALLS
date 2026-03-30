extends Control


@onready var play_icon: Sprite2D = $PlayIcon
@onready var pause_icon: Sprite2D = $PlayIcon/PauseIcon
@onready var play_icon_2: Sprite2D = $PlayIcon/PlayIcon2
@onready var pause_icon_2: Sprite2D = $PlayIcon/PauseIcon2
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var speed_icon_1x: Sprite2D = $SpeedIcon1x
@onready var speed_icon_2x: Sprite2D = $SpeedIcon2x
@onready var speed_icon_2x_enabled: Sprite2D = $SpeedIcon2x/SpeedIcon2xEnabled
@onready var speed_icon_3x: Sprite2D = $SpeedIcon3x
@onready var speed_icon_3x_enabled: Sprite2D = $SpeedIcon3x/SpeedIcon3xEnabled
@onready var play_button: Button = $PlayButton

var speed_position := 0.0
var speed_position_2 := 0.0
var started = false
var active = false

func _ready() -> void:
	hide()

func begin():
	speed_position = speed_icon_1x.position.y
	speed_position_2 = speed_position - 10
	if Engine.time_scale == 1.5:
		speed_icon_2x_enabled.show()
	elif Engine.time_scale == 2.0:
		speed_icon_2x_enabled.show()
		speed_icon_3x_enabled.show()
	show()
	anim.play("start")
	active = true
	play_button.disabled = false
	play_button.grab_focus()
	#await get_tree().create_timer(2.5, false).timeout

func goal():
	active = false
	started = false
	anim.play_backwards("start")
	pause_icon_2.hide()
	play_button.disabled = true
	await get_tree().create_timer(0.4, false).timeout
	hide()

func _on_play_button_mouse_entered() -> void:
	if get_tree().paused == true:
		return
	anim.play("hover")


func _on_play_button_mouse_exited() -> void:
	anim.play_backwards("hover")



func _on_play_button_pressed() -> void:
	if started == false:
		if get_parent().can_start == false:
			return
		#get_tree().current_scene.start()
		get_parent().start()
		started = true
		pause_icon_2.show()
	else:
		#get_tree().current_scene.reset()
		get_parent().reset()
		started = false
		pause_icon_2.hide()
		#play_icon_2.show()
		pause_icon.hide()

func press():
	started = true
	pause_icon_2.show()

func release():
	started = false
	pause_icon_2.hide()

#func _on_play_button_button_down() -> void:
	##play_icon.scale = Vector2(0.9, 0.9)
	#if started == false:
		#if get_parent().can_start == false:
			#return
		##get_tree().current_scene.start()
		#get_parent().start()
		#started = true
		#pause_icon_2.show()
	#else:
		##get_tree().current_scene.reset()
		#get_parent().reset()
		#started = false
		#pause_icon_2.hide()
		##play_icon_2.show()
		#pause_icon.hide()

#func _on_play_button_button_up() -> void:
	#play_icon.scale = Vector2(1.0, 1.0)
	#if started == true:
		#pause_icon_2.hide()
		#pause_icon.show()
	#else:
		#play_icon_2.hide()

func _input(event: InputEvent) -> void:
	if active == false:
		return
	if event.is_action("speedx1"):
		speedx1()
	elif event.is_action("speedx2"):
		speedx2()
	elif event.is_action("speedx3"):
		speedx3()

func _on_speedx_1_button_down() -> void:
	get_tree().current_scene.speedx1()
	speedx1()

func speedx1():
	speed_icon_2x_enabled.hide()
	speed_icon_3x_enabled.hide()
	get_parent().speedx1()


func _on_speedx_2_button_down() -> void:
	get_tree().current_scene.speedx2()
	speedx2()

func speedx2():
	speed_icon_2x_enabled.show()
	speed_icon_3x_enabled.hide()
	get_parent().speedx2()


func _on_speedx_3_button_down() -> void:
	get_tree().current_scene.speedx3()
	speedx3()

func speedx3():
	speed_icon_2x_enabled.show()
	speed_icon_3x_enabled.show()
	#get_tree().current_scene.speedx3()
	get_parent().speedx3()


func _on_speedx_1_mouse_entered() -> void:
	speed_icon_1x.position.y = speed_position_2


func _on_speedx_1_mouse_exited() -> void:
	speed_icon_1x.position.y = speed_position


func _on_speedx_2_mouse_entered() -> void:
	speed_icon_2x.position.y = speed_position_2


func _on_speedx_2_mouse_exited() -> void:
	speed_icon_2x.position.y = speed_position



func _on_speedx_3_mouse_entered() -> void:
	speed_icon_3x.position.y = speed_position_2


func _on_speedx_3_mouse_exited() -> void:
	speed_icon_3x.position.y = speed_position
