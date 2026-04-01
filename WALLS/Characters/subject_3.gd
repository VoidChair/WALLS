extends CharacterBody3D

@onready var forward: Area3D = $Looker/Forward
@onready var forward_coll: CollisionShape3D = $Looker/Forward/CollisionShape3D
@onready var left: RayCast3D = $Looker/Left
@onready var left_2: RayCast3D = $Looker/Left2

@onready var right: RayCast3D = $Looker/Right
@onready var right_2: RayCast3D = $Looker/Right2


@onready var pit_detect: RayCast3D = $Looker/PitDetect
@onready var pit_detect_2: RayCast3D = $Looker/PitDetect2



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
@onready var puzzle_cube: MeshInstance3D = $MeshControl/Subject3/Armature/Skeleton3D/ChestBone/PuzzleCube
@onready var forward_position: Node3D = $Looker/ForwardPosition

@onready var line_of_sight: Sprite3D = $MeshControl/Subject3/Armature/Skeleton3D/HeadBone/LineOfSightSprite

var cube: Node3D
var cube_hold = false

@onready var trail_timer: Timer = $TrailTimer
@onready var dots: Node3D = $Dots
const TRAIL = preload("res://Characters/subject_3_trail.tscn")

var can_move = false
var can_fall = false
var interrupt = false

var speed = 4.0
var acc = 10.0
var rot_acc = 10.0
var grav = -30.0
var ascend = false
var grounded = false
var test = 0

@onready var walk_sfx: AudioStreamPlayer = $WalkSFX
@onready var sit_sfx: AudioStreamPlayer = $SitSFX
@onready var sit_sfx_2: AudioStreamPlayer = $SitSFX2

func _ready() -> void:
	hide()

func begin():
	coll.set_deferred("disabled", false)
	looker.rotation.y = deg_to_rad(starting_rot)
	mesh.rotation.y = looker.rotation.y
	starting_position = global_position
	global_position.y += 30.0
	show()
	delay = (abs(global_position.x) + global_position.z) * 0.04 + 0.05
	await get_tree().create_timer(delay, false).timeout
	velocity.y = grav
	can_fall = true
	cube_anim.play("Spawn")
	#coll.set_deferred("disabled", true)
	#forward_coll.set_deferred("disabled", true)


func start():
	if dots.get_child_count() > 0:
		for c in dots.get_children():
			c.queue_free()
	can_move = true
	started = true
	await get_tree().create_timer(0.3, false).timeout
	trail_create()
	trail_timer.start()

func _physics_process(delta: float) -> void:
	if ascend == true:
		velocity.y = lerpf(velocity.y, 25, delta * 2)
	elif not is_on_floor() and can_fall == true:
		velocity.y += grav * delta 
		if grounded == true:
			grounded = false
			#if pit == true:
				#anim_tree["parameters/conditions/land"] = false
				#anim_tree["parameters/conditions/fall"] = true
	elif is_on_floor() and grounded == false:
		cube_anim.play("Drop")
		grounded = true
		#anim_tree["parameters/conditions/fall"] = false
		#anim_tree["parameters/conditions/land"] = true
	
	
	if left.is_colliding() or left_2.is_colliding():
		if left.is_colliding():
			if left.get_collider().is_in_group("cube"):
				left_turn = true
			else:
				left_turn = false
		elif left_2.is_colliding():
			if left_2.get_collider().is_in_group("cube"):
				left_turn = true
			else:
				left_turn = false
	else:
		left_turn = true
	
	if right.is_colliding() or right_2.is_colliding():
		if right.is_colliding():
			if right.get_collider().is_in_group("cube"):
				right_turn = true
			else:
				right_turn = false
		elif right_2.is_colliding():
			if right_2.get_collider().is_in_group("cube"):
				right_turn = true
			else:
				right_turn = false
	else:
		right_turn = true
	
	if not pit_detect.is_colliding()  and can_move == true or not pit_detect_2.is_colliding() and can_move == true:
		sit()
	
	line_of_sight.rotation.x = deg_to_rad(87.0)
	line_of_sight.rotation.z = 0
	
	if cube_hold == true:
		cube.global_position = global_position + Vector3(0, 1.5, 0)
	
	
	var direction := looker.transform.basis.z
	if can_move:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * acc)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * acc)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	mesh.rotation.y = lerp_angle(mesh.rotation.y, looker.rotation.y, delta * rot_acc)
	
	move_and_slide()
	
	
	
	anim_tree["parameters/Movement/IdleWalk/blend_position"] = lerpf(anim_tree["parameters/Movement/IdleWalk/blend_position"], abs(velocity.x) + abs(velocity.z), delta * 10)
	anim_tree["parameters/Movement/CubeHold/blend_position"] = lerpf(anim_tree["parameters/Movement/CubeHold/blend_position"], abs(velocity.x) + abs(velocity.z), delta * 10)
	


func reset():
	#anim_tree["parameters/conditions/left"] = false
	#anim_tree["parameters/conditions/right"] = false
	anim_tree["parameters/conditions/look"] = false
	anim_tree["parameters/conditions/ascend"] = false
	anim_tree["parameters/conditions/go"] = true
	anim_tree["parameters/conditions/stare"] = false
	anim_tree["parameters/conditions/sit"] = false
	anim_tree.active = false
	anim_tree.active = true
	anim_tree["parameters/Movement/IdleWalk/blend_position"] = 0
	anim_tree["parameters/Movement/CubeSwitch/blend_amount"] = 0
	anim_tree["parameters/LookLeft/blend_position"] = 0
	anim_tree["parameters/LookRight/blend_position"] = 0
	can_move = false
	started = false
	ascend = false
	walled = false
	interrupt = false
	velocity = Vector3(0, 0, 0)
	global_position = starting_position
	looker.rotation.y = deg_to_rad(starting_rot)
	mesh.rotation.y = looker.rotation.y
	cube_anim.stop()
	cube_anim.queue("Drop")
	puzzle_cube.hide()
	cube_hold = false
	trail_timer.stop()
	trail_timer.paused = false
	coll.set_deferred("disabled", false)
	if dots.get_child_count() > 0:
		for c in dots.get_children():
			c.pause()

func goal():
	coll.set_deferred("disabled", true)
	can_move = false
	ascend = true
	trail_timer.paused = true
	anim_tree["parameters/conditions/ascend"] = true
	cube_anim.play("Spin")
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

#func intersection():
	#if walled == true or interrupt == true or started == false:
		#return
	#can_move = false
	#walled = true
	##await get_tree().create_timer(0.2, false).timeout
	##position.x = snappedf(position.x, 0.5)
	##position.z = snappedf(position.z, 0.5)
	#print(global_position)
	#print(position)
	#if left_turn == true:
		#walled = false
		#looker.rotation.y += deg_to_rad(90)
		#cube_anim.play("CollisionReset")
		#can_move = true
		#walled = false
		#trail_timer.paused = false
		#return
	#if right_turn == true:
		#looker.rotation.y += deg_to_rad(-90)
	#else:
		#looker.rotation.y += deg_to_rad(180)
	#can_move = true
	#walled = false
	#cube_anim.play("CollisionReset")

func intersection():
	if walled == true or interrupt == true or started == false:
		return
	can_move = false
	walled = true
	anim_tree["parameters/conditions/go"] = false
	anim_tree["parameters/conditions/look"] = true
	trail_timer.paused = true
	cube_anim.play("Look")
	await get_tree().create_timer(0.6, false).timeout
	if started == false or interrupt == true or walled == false:
		return
	if right_turn == true:
		looker.rotation.y += deg_to_rad(-90)
		anim_tree["parameters/conditions/look"] = false
		anim_tree["parameters/conditions/go"] = true
		await get_tree().create_timer(0.1, false).timeout
		if started == false:
			return
		walled = false
		cube_anim.play("CollisionReset")
		can_move = true
		trail_timer.paused = false
		return
	await get_tree().create_timer(0.7, false).timeout
	if started == false or interrupt == true or walled == false:
		return
	if left_turn == true:
		looker.rotation.y += deg_to_rad(90)
	else:
		looker.rotation.y += deg_to_rad(180)
	anim_tree["parameters/conditions/look"] = false
	anim_tree["parameters/conditions/go"] = true
	await get_tree().create_timer(0.1, false).timeout
	if started == false or interrupt == true or walled == false:
		return
	walled = false
	cube_anim.play("CollisionReset")
	can_move = true
	trail_timer.paused = false

func walk():
	if can_move == false:
		return
	walk_sfx.volume_db = randf_range(-20, -15)
	#walk_sfx.pitch_scale = randf_range(2.0, 2.2)
	var flip = randi_range(1, 2)
	if flip == 1:
		walk_sfx.pitch_scale = 1.5
	else:
		walk_sfx.pitch_scale = 1.6
	walk_sfx.play()

func sit():
	can_move = false
	anim_tree["parameters/conditions/go"] = false
	anim_tree["parameters/conditions/stare"] = true
	cube_anim.play("Stare")
	trail_timer.stop()
	line_of_sight.hide()
	if cube_hold == true:
		cube_hold = false
		#cube_anim.play("Drop")
		puzzle_cube.hide()
		cube.velocity.y = 0.0
		cube.global_position = forward_position.global_position
		cube.show()
		cube.can_fall = true
		anim_tree["parameters/Movement/CubeSwitch/blend_amount"] = 0
		anim_tree["parameters/LookLeft/blend_position"] = 0
		anim_tree["parameters/LookRight/blend_position"] = 0
	await get_tree().create_timer(1.0, false).timeout
	if started == false:
		return
	sit_sfx.play()
	sit_sfx_2.play()
	anim_tree["parameters/conditions/sit"] = true
	anim_tree["parameters/conditions/stare"] = false
	get_tree().current_scene.contemplate()

func collide():
	if interrupt == true: 
		return
	can_move = false
	velocity = Vector3(0, 12, 0)
	interrupt = true
	walled = false
	anim_tree["parameters/conditions/launch"] = true
	anim_tree["parameters/conditions/look"] = false
	anim_tree["parameters/conditions/go"] = true
	cube_anim.play("Launch")
	await get_tree().create_timer(0.5, false).timeout
	anim_tree["parameters/conditions/launch"] = false
	await get_tree().create_timer(1.0, false).timeout
	if started == false:
		return
	interrupt = false
	if go_forward == true and pit == false:
		can_move = true
	else:
		intersection()


func released():
	can_fall = true
	coll.set_deferred("disabled", false)

func fall():
	if started == false:
		return
	cube_anim.play("Fall")
	await get_tree().create_timer(0.4, false).timeout
	if started == false:
		return
	can_fall = false
	velocity = Vector3(0, 0, 0)
	await get_tree().create_timer(0.6, false).timeout
	if started == false:
		return
	can_move = false
	cube_anim.play("Spawn")
	can_fall = true
	global_position = starting_position + Vector3(0, 30, 0)
	looker.rotation.y = deg_to_rad(starting_rot)
	mesh.rotation.y = looker.rotation.y
	await get_tree().create_timer(3.0, false).timeout
	if started == false:
		return
	can_move = true

func _on_forward_body_entered(body: Node3D) -> void:
	if body.is_in_group("environment") and walled == false and can_move == true:
		intersection()
	#elif body.is_in_group("cube") and cube_hold == false and can_move == true:
		#can_move = false
		#cube_anim.play("Hold")
		#cube = body
		##cube.hide()
		#cube_hold = true
		#anim_tree["parameters/Movement/CubeSwitch/blend_amount"] = 1
		#anim_tree["parameters/LookAround/blend_position"] = 1
		#anim_tree["parameters/Launch/blend_position"] = 1
		#cube.global_position -= Vector3(0, 5, 0)
		#cube.hide()
		#puzzle_cube.show()
		#await get_tree().create_timer(0.5, false).timeout
		#if started == false or interrupt == true:
			#return
		#if go_forward == true:
			#pass
		#elif left_turn == true:
			#looker.rotation.y += deg_to_rad(90)
		#elif right_turn == true:
			#looker.rotation.y += deg_to_rad(-90)
		#else:
			#looker.rotation.y += deg_to_rad(180)
		#cube_anim.play("CollisionReset")
		#can_move = true
	elif body.is_in_group("cube") and cube_hold == true and can_move == true:
		intersection()
	elif body.is_in_group("subject") and can_move == true and walled == false and body != self:
		intersection()


func _on_forward_area_entered(area: Area3D) -> void:
	if area.is_in_group("button") and cube_hold == true:
		can_move = false
		cube_anim.play("Drop")
		puzzle_cube.hide()
		cube_hold = false
		cube.place()
		area.activate()
		anim_tree["parameters/Movement/CubeSwitch/blend_amount"] = 0
		anim_tree["parameters/LookRight/blend_position"] = 0
		#anim_tree["parameters/LookAround/blend_position"] = 0
		#anim_tree["parameters/Launch/blend_position"] = 0
		await get_tree().create_timer(0.5, false).timeout
		intersection()
	elif area.is_in_group("cube") and cube_hold == false and can_move == true:
		can_move = false
		cube_anim.play("Hold")
		cube = area.get_parent()
		cube_hold = true
		anim_tree["parameters/Movement/CubeSwitch/blend_amount"] = 1
		anim_tree["parameters/LookRight/blend_position"] = 1
		#anim_tree["parameters/LookAround/blend_position"] = 1
		#anim_tree["parameters/Launch/blend_position"] = 1
		cube.can_fall = false
		cube.grab()
		puzzle_cube.show()
		await get_tree().create_timer(0.5, false).timeout
		if started == false or interrupt == true:
			return
		if go_forward == true:
			pass
		elif left_turn == true:
			looker.rotation.y += deg_to_rad(90)
		elif right_turn == true:
			looker.rotation.y += deg_to_rad(-90)
		else:
			looker.rotation.y += deg_to_rad(180)
		cube_anim.play("CollisionReset")
		can_move = true
	#elif area.is_in_group("cube") and cube_hold == true and can_move == true:
		#intersection()

func cube_release():
	can_move = false
	cube_anim.play("Drop")
	puzzle_cube.hide()
	cube_hold = false
	anim_tree["parameters/Movement/CubeSwitch/blend_amount"] = 0
	anim_tree["parameters/LookAround/blend_position"] = 0
	anim_tree["parameters/Launch/blend_position"] = 0
	anim_tree["parameters/LookRight/blend_position"] = 0
	await get_tree().create_timer(0.5, false).timeout
	intersection()


func _on_trail_timer_timeout() -> void:
	trail_create()

func trail_create():
	var dot = TRAIL.instantiate()
	dots.add_child(dot)
	dot.global_position = global_position
