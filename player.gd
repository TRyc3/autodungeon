extends Node2D

var move = false
var velocity = Vector2()
const mspeed = 5000

func get_input():
	if Input.is_action_just_pressed("cmd_up"):
		velocity = Vector2(0, -1)
		move = true
	if Input.is_action_just_pressed("cmd_down"):
		velocity = Vector2(0, 1)
		move = true
	if Input.is_action_just_pressed("cmd_right"):
		velocity = Vector2(1, 0)
		move = true
	if Input.is_action_just_pressed("cmd_left"):
		velocity = Vector2(-1, 0)
		move = true

func _ready():
	pass

func _process(delta):
	var timer = 0 
	if move == false:
		get_input()
	if move == true:
		timer = 0
	while timer < 4000 && move == true:
		$body.move_and_slide(velocity) * mspeed
		timer += 1
	if timer >= 1000:
		move = false
		timer = 0

