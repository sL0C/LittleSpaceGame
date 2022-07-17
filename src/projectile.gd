extends Node2D



export(float) var max_speed = 100

var velocity: = Vector2.ZERO
var vel_direction: = Vector2.ZERO # Direction of the velocity
#var move_direction: = Vector2.ZERO  # Direction in which he should move to
var accleration: = Vector2.ZERO
var acc_direction: = Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	move()

func update():
	# Movement logic
	velocity += accleration
	velocity = velocity.limit_length(max_speed)
	acc_direction = accleration.normalized()
	vel_direction = velocity.normalized()
	accleration *= 0 # Reset accleration.

func move():
	update()




















