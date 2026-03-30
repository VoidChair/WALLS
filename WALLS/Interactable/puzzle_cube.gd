extends CharacterBody3D

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var coll: CollisionShape3D = $CollisionShape3D
@onready var area_coll: CollisionShape3D = $Area3D/CollisionShape3D
@onready var sfx: AudioStreamPlayer = $SFX
@onready var sfx_2: AudioStreamPlayer = $SFX2
@export var subject_3: Node3D
var delay := 0.05
var acc := 10.0
var grav := -30.0
var knockback := 24.0
var can_fall = false
var grounded = false
var started = false
var starting_pos : Vector3
var ascend = false
var active = false


func _ready() -> void:
	anim.play("hidden")

func begin():
	coll.set_deferred("disabled", false)
	area_coll.set_deferred("disabled", false)
	if starting_pos: 
		pass
	else:
		starting_pos = global_position
	global_position.y = 30
	delay = (abs(global_position.x) + global_position.z) * 0.04
	await get_tree().create_timer(delay, false).timeout
	velocity.y = grav
	active = true
	can_fall = true
	anim.play("start")
	show()
	if Engine.time_scale == 1:
		speedx1()
	elif Engine.time_scale == 1.5:
		speedx2()
	elif Engine.time_scale == 2:
		speedx3()

func _physics_process(delta: float) -> void:
	if active == false:
		return
	if ascend == true:
		velocity.y += grav * delta * -1
	elif not is_on_floor() and can_fall == true:
		velocity.y += grav * delta 
		grounded = false
	elif is_on_floor() and grounded == false:
		grounded = true
		anim.play("squash")
	
	velocity.x = lerp(velocity.x, 0.0, delta * acc)
	velocity.z = lerp(velocity.z, 0.0, delta * acc)
	
	move_and_slide()

func launch(v, r):
	global_rotation.y = r
	anim.play("launch")
	velocity.x = v.x * knockback
	velocity.z = v.z * knockback
	can_fall = false
	sfx.play()
	await get_tree().create_timer(0.3, false).timeout
	if started == false:
		return
	can_fall =  true

func start():
	started = true
	can_fall = true
	coll.set_deferred("disabled", false)
	area_coll.set_deferred("disabled", false)

func goal():
	#await get_tree().create_timer(clamp((delay * -1) + 1.0, 0, 2), false).timeout
	#anim.play_backwards("start")
	ascend = true
	coll.set_deferred("disabled", true)
	area_coll.set_deferred("disabled", true)
	await get_tree().create_timer(2.0, false).timeout
	active = false
	ascend = false
	can_fall = false

func speedx1():
	knockback = 24.0

func speedx2():
	knockback = 27.0

func speedx3():
	knockback = 30.0

func place():
	#if subject_3:
		#subject_3.new_target(self)
	can_fall = false
	global_position += Vector3(0, 10, 0)
	coll.set_deferred("disabled", true)
	sfx_2.play()

func grab():
	hide()
	sfx.play()
	coll.set_deferred("disabled", true)

func fall():
	anim.play("fall")
	await get_tree().create_timer(0.4, false).timeout
	if started == false:
		return
	can_fall = false
	velocity = Vector3(0, 0, 0)
	await get_tree().create_timer(0.6, false).timeout
	anim.play("start")
	global_position = starting_pos + Vector3(0, 30, 0)
	can_fall = true

func reset():
	ascend = false
	velocity = Vector3(0, 0, 0)
	started = false
	global_position = starting_pos
	show()
	can_fall = false
	coll.set_deferred("disabled", true)
	area_coll.set_deferred("disabled", true)
	await get_tree().create_timer(0.1, false).timeout
	global_position = starting_pos
