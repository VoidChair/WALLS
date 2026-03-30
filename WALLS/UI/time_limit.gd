extends Control

@onready var timer: Timer = $Timer
@onready var time_label: Label = $TimeLabel
var time = 20
@onready var anim: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	anim.play("start")

func time_set():
	timer.wait_time = time
	time_label.text = str(time) + ".000"

func start():
	return
	#timer.start()

func stop():
	timer.paused = true

func reset():
	timer.stop()
	time_set()

func _on_timer_timeout() -> void:
	get_parent().reset()
	reset()

func _physics_process(_delta: float) -> void:
	if timer.is_stopped() == false:
		time_label.text = "%02d.%03d" % time_left_till_loop()

func time_left_till_loop():
	var time_left = timer.time_left
	var second = int(time_left) % 60
	var millisecond = int(time_left * 1000.0) % 1000
	return [second, millisecond]
