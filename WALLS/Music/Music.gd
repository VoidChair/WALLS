extends Node3D


@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var music: AudioStreamPlayer = $Music
var main_vol := -5.0
var bass_vol := -40.0
var drum_vol := -40.0
var paused = false
var acc := 1.0
var contemplating = false

func begin():
	#main.volume_db = -80.0
	#bass.volume_db = -20.0
	#drums.volume_db = -40.0
	acc = 0.25
	main_vol = -5.0
	bass_vol = -20.0
	drum_vol = -40.0
	await get_tree().create_timer(1.7, false).timeout
	anim.play("RESET")
	music.play()
	#print("hi")

func false_start():
	#print("huh?")
	#anim.play("start")
	music.play()
	await get_tree().create_timer(0.1, false).timeout
	music.stop()

func contemplate():
	anim.stop()
	anim.play("conpemplate")
	contemplating = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#if get_tree().paused == false:
		#if paused == true:
			#paused = false
			#main.volume_db = main_vol
			#bass.volume_db = bass_vol
			#drums.volume_db = drum_vol
		#main.volume_db = lerpf(main.volume_db, main_vol, delta * acc)
		#bass.volume_db = lerpf(bass.volume_db, bass_vol, delta * acc)
		#drums.volume_db = lerpf(drums.volume_db, drum_vol, delta * acc)
	#else:
		#paused = true
		#main.volume_db = -10.0
		#bass.volume_db = bass_vol - 10.0
		#drums.volume_db = drum_vol - 10.0

func start():
	anim.play("movement")
	#acc = 5.0
	#main_vol = 0.0
	#bass_vol = -5.0
	#drum_vol = -5.0
	#drums.seek(main.get_playback_position())
	#bass.seek(main.get_playback_position())
	#main.volume_db = main_vol
	#bass.volume_db = bass_vol
	#drums.volume_db = drum_vol

func stop():
	if contemplating == true:
		anim.stop()
		anim.play("lock_in")
	else:
		anim.play_backwards("movement")
	contemplating = false
	#acc = 2.0
	#main_vol = -5.0
	#bass_vol = -20.0
	#drum_vol = -40.0
	#main.volume_db = main_vol
	#bass.volume_db = bass_vol
	#drums.volume_db = drum_vol

func deafen():
	music.volume_db = -5.0

func undeafen():
	music.volume_db = 0.0
