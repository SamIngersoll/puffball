class_name Enemy extends CharacterBody3D


enum State {
	WANDER,
	CHASE,
	DYING,
	DEAD
}

const wander_speed = 1.0 as float
const chase_speed = 5.0 as float
var speed = wander_speed

@export var health := 20 as int
var _state := State.WANDER
var player_found : bool = false
var last_known_player_location : Vector3

@onready var gravity: int = ProjectSettings.get("physics/3d/default_gravity")

@onready var floor_detector_left := $raycast_floor_detector/FloorDetectorLeft as RayCast3D
@onready var floor_detector_right := $raycast_floor_detector/FloorDetectorRight as RayCast3D
@onready var wall_detection_left := $raycast_wall_detector/WallDetectionLeft as RayCast3D
@onready var wall_detection_right := $raycast_wall_detector/WallDetectionRight as RayCast3D
@onready var player_detection_front := $raycast_player_detector/PlayerDetectionFront as RayCast3D
@onready var player_detection_rear := $raycast_player_detector/PlayerDetectionRear as RayCast3D

@onready var sprite := $Sprite3D as Sprite3D
@onready var animation_player := $AnimationPlayer as AnimationPlayer
@onready var chase_timer := $chase_timer as Timer

func _ready():
	velocity.x = wander_speed

func _physics_process(delta: float) -> void:
	if _state != State.DEAD and _state != State.DYING:
		if _state == State.WANDER:
			speed = sign(velocity.x)*wander_speed
		elif _state == State.CHASE:
			if last_known_player_location.x > position.x:
				speed = chase_speed
			elif last_known_player_location.x < position.x:
				speed = -chase_speed
		
		velocity.x = speed

		handle_vision()
		#if velocity.x > 0.0:
			#sprite.scale.x = abs(sprite.scale.x)
			#player_detection_front.scale.x = player_detection_front.scale.x
			#player_detection_rear.scale.x = player_detection_rear.scale.x
		#elif velocity.x < 0.0:
			#

		var animation := get_new_animation()
		if animation != animation_player.current_animation:
			animation_player.play(animation)
			
		velocity.y -= gravity * delta
		move_and_slide()

func handle_vision():
	var need_to_turn = false
	if wall_detection_left.is_colliding() and velocity.x < 0:
		print("COLLIDING LEFT")
		need_to_turn = true
	elif wall_detection_right.is_colliding() and velocity.x > 0:
		print("COLLIDING RIGHT")
		need_to_turn = true
	if not floor_detector_left.is_colliding() and velocity.x < 0:
		print("FLOOR NOT COLLIDING LEFT")
		need_to_turn = true
	elif not floor_detector_right.is_colliding() and velocity.x > 0:
		print("FLOOR NOT COLLIDING RIGHT")
		need_to_turn = true
	if player_detection_front.is_colliding():
		print("player detection FRONT")
		player_found = true
		need_to_turn = false
		_state = State.CHASE
		chase_timer.start(1)
		last_known_player_location = player_detection_front.get_collision_point()
	elif player_detection_rear.is_colliding():
		print("player detection REAR")
		player_found = true
		_state = State.CHASE
		chase_timer.start(1)
		last_known_player_location = player_detection_rear.get_collision_point()
		need_to_turn = true
	else:
		player_found = false 
	if need_to_turn:
		turn_around()

		
func turn_around() -> void:
	sprite.scale.x = -1*(sprite.scale.x)
	velocity.x = -1*(velocity.x)
	player_detection_front.scale.x = -player_detection_front.scale.x
	player_detection_rear.scale.x = -player_detection_rear.scale.x

func reduce_health(damage) -> void:
	health -= damage
	update_health()

func update_health() -> void:
	if health <= 0:
		_state = State.DYING
		velocity = Vector3.ZERO
		animation_player.play(&"destroy")

func get_new_animation() -> StringName:
	var animation_new: StringName
	if _state == State.WANDER:
		if velocity.x == 0:
			animation_new = &"idle"
		else:
			animation_new = &"walk"
	elif _state == State.CHASE:
		animation_new = &"walk"
	elif _state == State.DYING:
		pass
	else:
		self.queue_free() # Replace with function body.
	return animation_new

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "destroy()":
		_state = State.DEAD

func _on_chase_timer_timeout():
	print("TIMEOUT")
	_state = State.WANDER 
