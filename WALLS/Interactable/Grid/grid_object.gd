extends StaticBody3D


var delay := 0.05
@onready var coll: CollisionShape3D = $CollisionShape3D
@onready var invalid: MeshInstance3D = $Control/Block1/Invalid
@onready var invalid_2: MeshInstance3D = $Control/Block2/Invalid2
@onready var ray: RayCast3D = $Control/Block1/RayCast3D
@onready var ray_2: RayCast3D = $Control/Block2/RayCast3D2
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var outline: MeshInstance3D = $Control/Block1/Outline

@onready var thud: AudioStreamPlayer = $Thud
@onready var thud_2: AudioStreamPlayer = $Thud2
@onready var click: AudioStreamPlayer = $Click
@onready var click_2: AudioStreamPlayer = $Click2

var grabbed = true
var is_invalid_1 = false
var is_invalid_2 = false
var rot := 90.0
var started = false
var starting_position = Vector3(0, 0, 0)
var starting_rotation = 0.0

func _ready() -> void:
	anim.play("hidden")

func begin():
	delay = (abs(global_position.x) + global_position.z) * 0.04
	await get_tree().create_timer(delay, false).timeout
	anim.play("start")
	await get_tree().create_timer(0.6, false).timeout
	started = true
	invalid.hide()
	invalid_2.hide()
	starting_position = global_position

func goal():
	started = false
	delay = (abs(global_position.x) + global_position.z) * 0.05 + 0.1
	await get_tree().create_timer((delay * -1) + 2.0, false).timeout
	anim.play_backwards("start")

func _process(_delta: float) -> void:
	if started == false:
		return
	if ray.is_colliding():
		if ray.get_collider().is_in_group("grid"):
			invalid.hide()
			if is_invalid_1 == true:
				is_invalid_1 = false
				get_tree().current_scene.invalid -= 1
				#get_parent_node_3d().get_parent_node_3d().invalid -= 1
		else:
			invalid.show()
			if is_invalid_1 == false:
				is_invalid_1 = true
				get_tree().current_scene.invalid += 1
				#get_parent_node_3d().get_parent_node_3d().invalid += 1
	else:
		invalid.show()
		if is_invalid_1 == false:
			is_invalid_1 = true
			get_tree().current_scene.invalid += 1
			#get_parent_node_3d().get_parent_node_3d().invalid += 1
		
	if ray_2.is_colliding():
		if ray_2.get_collider().is_in_group("grid"):
			invalid_2.hide()
			if is_invalid_2 == true:
				is_invalid_2 = false
				get_tree().current_scene.invalid -= 1
				#get_parent_node_3d().get_parent_node_3d().invalid -= 1
		else:
			invalid_2.show()
			if is_invalid_2 == false:
				is_invalid_2 = true
				get_tree().current_scene.invalid += 1
				#get_parent_node_3d().get_parent_node_3d().invalid += 1
	else:
		invalid_2.show()
		if is_invalid_2 == false:
			is_invalid_2 = true
			get_tree().current_scene.invalid += 1
			#get_parent_node_3d().get_parent_node_3d().invalid += 1

func hover():
	outline.show()

func unhover():
	outline.hide()

func grab():
	coll.set_deferred("disabled", true)
	anim.play("Hovered")
	#get_tree().current_scene.can_start = false
	get_parent_node_3d().get_parent_node_3d().can_start = false

func release():
	coll.set_deferred("disabled", false)
	#thud.pitch_scale = randf_range(0.9, 1.1)
	anim.play("Unhovered")
	#get_tree().current_scene.can_start = true
	get_parent_node_3d().get_parent_node_3d().can_start = true

func get_rotated():
	rot *= -1
	rotation.y += deg_to_rad(rot)
	click.play()
	anim.play("Squish")

func reset():
	global_position = starting_position
	rotation.y = starting_rotation

func _on_block_area_1_area_entered(area: Area3D) -> void:
	if area.is_in_group("block") and grabbed == true and started == true:
		ray.position.y -= 5
		if is_invalid_1 == false:
			is_invalid_1 = true
			get_tree().current_scene.invalid += 1
			#get_parent_node_3d().get_parent_node_3d().invalid += 1
			invalid.show()


func _on_block_area_1_area_exited(area: Area3D) -> void:
	if area.is_in_group("block") and grabbed == true and started == true:
		ray.position.y += 5
		if ray.is_colliding():
			if ray.get_collider().is_in_group("grid"):
				is_invalid_1 = false
				get_tree().current_scene.invalid -= 1
				#get_parent_node_3d().get_parent_node_3d().invalid -= 1
				invalid.hide()


func _on_block_area_2_area_entered(area: Area3D) -> void:
	if area.is_in_group("block") and grabbed == true and started == true:
		ray_2.position.y -= 5
		if is_invalid_2 == false:
			is_invalid_2 = true
			get_tree().current_scene.invalid += 1
			#get_parent_node_3d().get_parent_node_3d().invalid += 1
			invalid_2.show()


func _on_block_area_2_area_exited(area: Area3D) -> void:
	if area.is_in_group("block") and grabbed == true and started == true:
		ray_2.position.y += 5
		if ray_2.is_colliding():
			if ray_2.get_collider().is_in_group("grid"):
				is_invalid_2 = false
				get_tree().current_scene.invalid -= 1
				#get_parent_node_3d().get_parent_node_3d().invalid -= 1
				invalid_2.hide()
