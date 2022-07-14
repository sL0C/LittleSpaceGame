extends KinematicBody2D 
class_name Actor

const DIAGONAL_FIX:float = 0.707 # That's just magical 

# Member Variables
export var mass:float = 1
export var rotation_dir:float = .0
export var current_dir:Vector2 = Vector2.ZERO

export var thrust_strength:float = 10
export var run_strength:float = 25
export var sneak_strength:float = 5
export var turn_strength: float = 0.005

export var health_recovery:float = 0.5 	# The amount by which to increase health.
export var health:float = 100
export var stamina_recovery:float = 1 	# The amount by which to increase stamina.
export var stamina:float = 100
export var strain:float = 0.5 			# The amount by which to decrease stamina while running.
export var recovery_cicle:float = 0.5

export var max_speed:float = 400
export var max_health:float = 100
export var max_stamina:float = 100
export var max_turn_speed:float = 0.1

# Physic Forces
var linear_velocity = 0
export (float) var drag_strength:float = 0.001 # The strength of drag. (0 = Vacuum)
export (float) var static_friction:float = 1 # The friction which applies, when the object is not moving.
export (float) var kinetic_friction:float = 4 # The strength of kinetic friction applies, when the object is moving.
export (int, 0, 200) var inertia = 5

# States
var alive = true
var walking = false
var running = false
var sneaking = false
var attacking = false

# Signals
signal started_walking
signal stopped_walking
signal is_walking
signal started_running
signal stopped_running
signal is_running
signal started_sneaking
signal stopped_sneaking
signal is_sneaking
signal started_attacking
signal stopped_attacking
signal damaged(amount)
signal recovered_health
signal recovered_stamina

# Activater
export var active_drag = true
export var active_friction = true
#export onready var sneaking_sound = $AudioStreamPlayer

# Built-in Vector Types
var drag: = Vector2.ZERO
var friction: = Vector2.ZERO
var velocity: = Vector2.ZERO
var vel_direction: = Vector2.ZERO # Direction of the velocity
#var move_direction: = Vector2.ZERO  # Direction in which he should move to
var accleration: = Vector2.ZERO
var acc_direction: = Vector2.ZERO

#onready var tween:Tween = $Tween
onready var recovery_timer:Timer = $RecoveryTimer
#onready var foot_steps:Node2D = $FootSteps
onready var sprite:Sprite = $Sprite
onready var collision_polygon:CollisionPolygon2D = $CollisionPolygon2D

func _ready():
	self.add_to_group("Actor")

	#TODO: Add polygon creation here

	recovery_timer.set_wait_time(recovery_cicle)
	recovery_timer.start()
	recovery_timer.connect('timeout', self, 'recover_stamina')
	recovery_timer.connect('timeout', self, 'recover_health')

func _physics_process(delta:float) -> void:
	if active_friction: apply_friction()
	if active_drag: apply_drag()

	update()
	
	move_and_slide(velocity, Vector2.ZERO, false, 4, PI/4, false)
	linear_velocity = velocity.length() # Get the linear velocity of the actor
	
	# Collision rule for RigidBodys2D
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		if collision.collider.is_in_group("bodies"):
			collision.collider.apply_central_impulse(-collision.normal * inertia)

func _apply_polygons(polygons:Array) -> void:
	for polygon in polygons:
		var collider = CollisionPolygon2D.new()
		collider.polygon = polygon
		add_child(collider)

# Apply a force, like wind, friction, drag, gravity, etc.
func apply_force(force:Vector2) -> void:
	accleration += force / mass # Accleration is equal to the force devided by mass.
	
#func knock_back(dir:Vector2, knock_strength:float, duration:float) -> void:
#	tween.interpolate_property(self, "accleration", accleration,  dir * knock_strength, duration, Tween.TRANS_EXPO, Tween.EASE_OUT)
#	tween.start()

# VELOCITY & DIRECTION
func update() -> void:
	current_dir = Vector2(cos(rotation), sin(rotation))
	rotation += clamp(rotation_dir, -max_turn_speed, max_turn_speed)
	velocity += accleration
	velocity = velocity.limit_length(max_speed)
	acc_direction = accleration.normalized()
	vel_direction = velocity.normalized()
	accleration *= 0 # Reset accleration.
	
# FRICTION
func calc_friction() -> Vector2:
	if velocity.length() <= static_friction: 
		return velocity * -1
	return (velocity.normalized() * -1 * kinetic_friction)
		 
func apply_friction() -> void:
	friction = calc_friction()
	apply_force(friction)
	
	# DRAG
func calc_drag() -> Vector2:
	var speed_sqr = velocity.length_squared() #Get the current speed squared
	var drag_mag = drag_strength * speed_sqr #Calculate the length of the drag force
	return (velocity.normalized() * -1 * drag_mag)
	
func apply_drag() -> void:
	drag = calc_drag()
	apply_force(drag)	

	# STAMINA & HEALTH
func strain_stamina(amount:float) -> void:
	if stamina >= -amount:
		stamina -= amount
	if stamina < 0:
		stamina = 0
			
func recover_stamina() -> void:
	if stamina < max_stamina and (stamina + stamina_recovery) <= (max_stamina + stamina_recovery-1):
		stamina += stamina_recovery
		emit_signal('recovered_stamina')
		print('Recovered Stamina!', self.stamina)

func recover_health() -> void:
	if health < max_health and (health + health_recovery) <= (max_health + health_recovery):
		health += health_recovery
		emit_signal('recovered_health')
	
###############################

# Fixes the diagonal speed-up mechanic for being realistic
func fix_diagonal_speed(v:Vector2) -> Vector2:
	if v.length() > 1:
		return v * DIAGONAL_FIX
	return v

# Applies thrust to the current direction of the velocity.
func give_thrust() -> void:
	apply_force( current_dir * thrust_strength )

func turn_right() -> void:
	rotation_dir += turn_strength

func turn_left() -> void:
	rotation_dir -= turn_strength

# ATTACK
func start_attacking() -> void:
	attacking = true
	emit_signal("started_attacking")
	
func stop_attacking() -> void:
	attacking = false
	emit_signal("stopped_attacking")

# Applies damage to the actor.
func set_damage(amount:float) -> void:
	health -= amount
	if health <= 0:
		alive = false
	emit_signal("damaged")
