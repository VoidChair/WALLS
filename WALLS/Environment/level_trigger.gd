extends Area3D


@export var level := "1"
@export var next := 1
@export var end := false
@onready var level_number: Label3D = $Cube1/LevelNumber
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var color: AnimationPlayer = $Color
@onready var sfx: AudioStreamPlayer = $SFX
@onready var area_coll: CollisionShape3D = $CollisionShape3D
var delay := 0.05
var active = false

#func _ready() -> void:
func begin():
	if get_tree().current_scene.saveData.levels[next] == 0:
		color.play("locked")
		area_coll.set_deferred("disabled", true)
	elif get_tree().current_scene.saveData.levels[next] == 1:
		color.play("unlocked")
		area_coll.set_deferred("disabled", false)
		show()
		position.y = 0
	elif get_tree().current_scene.saveData.levels[next] == 2:
		color.play("completed")
		area_coll.set_deferred("disabled", false)
		show()
		position.y = 0
	if end == true:
		level_number.text = "?"
	else:
		level_number.text = level
	anim.play("hidden")
	delay = (abs(global_position.x) + global_position.z) * 0.04
	await get_tree().create_timer(delay, false).timeout
	anim.play("start")
	active = true

func goal():
	active = false
	await get_tree().create_timer((delay * -1) + 2.0, false).timeout
	anim.play_backwards("start")

func _on_body_entered(body: Node3D) -> void:
	if active == false:
		return
	if body.is_in_group("subject"):
		active = false
		body.goal()
		sfx.play()
		#get_tree().current_scene.level(level)
		get_tree().current_scene.goal()
		get_parent_node_3d().get_parent_node_3d().next = next
		#get_tree().current_scene.next_level(next)

func locked():
	color.play("locked")

func unlocked():
	color.play("unlocked")

func completed():
	color.play("completed")
