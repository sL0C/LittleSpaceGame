extends Area2D
class_name Projectile

export(float) var speed = 800
export(float) var max_speed = 100
export(float) var livespan = 1
onready var area = get_node('.')

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _physics_process(delta):
	position += transform.x * speed * delta + Global.players[0].velocity / 100
























