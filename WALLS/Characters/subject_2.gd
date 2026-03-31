extends CharacterBody3D

@onready var forward: Area3D = $Looker/Forward
@onready var forward_coll: CollisionShape3D = $Looker/Forward/CollisionShape3D
@onready var left: RayCast3D = $Looker/Left
@onready var left_2: RayCast3D = $Looker/Left2

@onready var right: RayCast3D = $Looker/Right
@onready var right_2: RayCast3D = $Looker/Right2

@onready var front: RayCast3D = $Looker/Front
@onready var pit_detect: RayCast3D = $Looker/PitDetect
@onready var pit_detect_right: RayCast3D = $Looker/PitDetectRight
@onready var pit_detect_left: RayCast3D = $Looker/PitDetectLeft


var left_turn = true
var right_turn = true
var go_forward = true
var walled = false
var pit = false

@export var starting_rot := 0.0
var starting_position := Vector3(0, 0, 0)
var started = false
var delay := 0.05

@onready var looker: Node3D = $Looker

@onready var mesh: Node3D = $MeshControl
@onready var coll: CollisionShape3D = $CollisionShape3D

@onready var anim_tree: AnimationTree = $AnimationTree

@onready var cube_anim: AnimationPlayer = $CubeInteractAnim
var cube: Node3D
var cube_hold = false

@onready var trail_timer: Timer = $TrailTimer
@onready var dots: Node3D = $Dots
const TRAIL = preload("res://Characters/subject_2_trail.tscn")

var can_move = false
var can_fall = false

var speed = 7.0
var acc = 20.0
var rot_acc = 10.0
var grav = -30.0
var ascend = false
var grounded = false
var active = false

@onready var bonk_sfx: AudioStreamPlayer = $BonkSFX
@onready var bonk_sfx_2: AudioStreamPlayer = $BonkSFX2
@onready var walk_sfx: AudioStreamPlayer = $WalkSFX
@onready var fall_sfx: AudioStreamPlayer = $FallSFX

func _ready() -> void:
	hide()

func begin():
	coll.set_deferred("disabled", false)
	looker.rotation.y = deg_to_rad(starting_rot)
	mesh.rotation.y = looker.rotation.y
	starting_position = global_position
	global_position.y = 30.0
	show()
	delay = (abs(global_position.x) + global_position.z) * 0.04 + 0.05
	await get_tree().create_timer(delay, false).timeout
	velocity.y = grav
	active = true
	grounded = false
	can_fall = true
	anim_tree["parameters/conditions/land"] = false
	anim_tree["parameters/conditions/fall"] = true
	cube_anim.play("Spawn")
	#coll.set_deferred("disabled", true)
	#forward_coll.set_deferred("disabled", true)


func start():
	if dots.get_child_count() > 0:
		for c in dots.get_children():
			c.queue_free()
	can_move = true
	started = true
	trail_timer.start()

func _physics_process(delta: float) -> void:
	if active == false:
		return
	if ascend == true:
		velocity.y = lerpf(velocity.y, 25, delta * 2)
	elif not is_on_floor() and can_fall == true:
		velocity.y += grav * delta 
		if grounded == true:
			grounded = false
			if pit == true:
				anim_tree["parameters/conditions/land"] = false
				anim_tree["parameters/conditions/fall"] = true
	elif is_on_floor() and grounded == false:
		cube_anim.play("Drop")
		grounded = true
		anim_tree["parameters/conditions/fall"] = false
		anim_tree["parameters/conditions/land"] = true
	
	if pit_detect.is_colliding():
		pit = false
	else:
		pit = true
	
	var direction := looker.transform.basis.z
	if can_move == true and grounded == true:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * acc)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * acc)
	else:
		velocity.x = lerp(velocity.x, 0.0, delta * acc)
		velocity.z = lerp(velocity.z, 0.0, delta * acc)
	
	mesh.rotation.y = lerp_angle(mesh.rotation.y, looker.rotation.y, delta * rot_acc)
	
	move_and_slide()
	
	
	
	anim_tree["parameters/Movement/blend_position"] = lerpf(anim_tree["parameters/Movement/blend_position"], abs(velocity.x) + abs(velocity.z), delta * 10)



func reset():
	anim_tree.active = false
	anim_tree.active = true
	grounded = true
	anim_tree["parameters/conditions/fall"] = false
	anim_tree["parameters/conditions/land"] = true
	anim_tree["parameters/Movement/blend_position"] = 0
	can_move = false
	can_fall = true
	started = false
	ascend = false
	walled = false
	global_position = starting_position
	looker.rotation.y = deg_to_rad(starting_rot)
	mesh.rotation.y = looker.rotation.y
	velocity = Vector3(0, 0, 0)
	cube_anim.stop()
	cube_anim.queue("Drop")
	cube_hold = false
	trail_timer.stop()
	trail_timer.paused = false
	coll.set_deferred("disabled", false)
	if dots.get_child_count() > 0:
		for c in dots.get_children():
			c.pause()

func goal():
	coll.set_deferred("disabled", true)
	can_fall = false
	can_move = false
	ascend = true
	cube_anim.play("Spin")
	trail_timer.paused = true
	await get_tree().create_timer(3.0, false).timeout
	ascend = false
	can_fall = false

func end():
	can_move = false
	ascend = true
	trail_timer.paused = true
	if dots.get_child_count() > 0:
		for c in dots.get_children():
			c.disappear()
	await get_tree().create_timer(3.0, false).timeout
	ascend = false
	can_fall = false
	active = false

func bonk():
	anim_tree["parameters/conditions/bonk"] = true
	can_move = false
	trail_timer.paused = true
	walled = true
	velocity = Vector3(0, 0, 0)
	#velocity = mesh.transform.basis.z * -5.0
	#global_position.x = snappedf(global_position.x, 1.0)
	#global_position.z = snappedf(global_position.z, 1.0)
	bonk_sfx.pitch_scale = randf_range(1.1, 1.3)
	bonk_sfx.play()
	bonk_sfx_2.play()
	await get_tree().create_timer(0.5, false).timeout
	anim_tree["parameters/conditions/bonk"] = false
	await get_tree().create_timer(0.6, false).timeout
	if started == false or walled == false:
		return
	looker.rotation.y += deg_to_rad(-90)
	cube_anim.play("CollisionReset")
	await get_tree().create_timer(0.1, false).timeout
	walled = false
	can_move = true
	trail_timer.paused = false

func walk():
	if can_move == false:
		return
	walk_sfx.volume_db = randf_range(-20, -15)
	#walk_sfx.pitch_scale = randf_range(2.0, 2.2)
	var flip = randi_range(1, 2)
	if flip == 1:
		walk_sfx.pitch_scale = 2.4
	else:
		walk_sfx.pitch_scale = 2.6
	walk_sfx.play()

func fall():
	if started == false:
		return
	cube_anim.play("Fall")
	await get_tree().create_timer(0.3, false).timeout
	if started == false:
		return
	can_fall = false
	velocity = Vector3(0, 0, 0)
	await get_tree().create_timer(0.7, false).timeout
	if started == false:
		return
	can_move = false
	trail_timer.paused = true
	cube_anim.play("Spawn")
	can_fall = true
	global_position = starting_position + Vector3(0, 30, 0)
	looker.rotation.y = deg_to_rad(starting_rot)
	mesh.rotation.y = looker.rotation.y
	await get_tree().create_timer(3.0, false).timeout
	if started == false:
		return
	trail_timer.paused = false
	can_move = true


func _on_forward_body_entered(body: Node3D) -> void:
	if body.is_in_group("environment") and walled == false and can_move == true:
		bonk()
	elif body.is_in_group("cube") and walled == false and can_move == true:
		bonk()
		body.launch(looker.transform.basis.z, looker.global_rotation.y)
	elif body.is_in_group("subject") and can_move == true and body != self:
		#bonk()
		body.collide()


func _on_trail_timer_timeout() -> void:
	var dot = TRAIL.instantiate()
	dots.add_child(dot)
	dot.global_position = global_position
