class_name Enemy extends CharacterBody2D


enum State {
	WANDER,
	CHASE,
	DYING,
	DEAD
}

const wander_speed = 22.0 as float
const chase_speed = 100.0 as float
var speed = wander_speed

@export var health := 20 as int
var _state := State.WANDER
var player_found : bool = false
var last_known_player_location : Vector2

@onready var gravity: int = ProjectSettings.get("physics/2d/default_gravity")

@onready var floor_detector_left := $raycast_floor_detector/FloorDetectorLeft as RayCast2D
@onready var floor_detector_right := $raycast_floor_detector/FloorDetectorRight as RayCast2D
@onready var wall_detection_left := $raycast_wall_detector/WallDetectionLeft as RayCast2D
@onready var wall_detection_right := $raycast_wall_detector/WallDetectionRight as RayCast2D
@onready var player_detection_front := $raycast_player_detector/PlayerDetectionFront as RayCast2D
@onready var player_detection_rear := $raycast_player_detector/PlayerDetectionRear as RayCast2D

@onready var sprite := $Sprite2D as Sprite2D
@onready var animation_player := $AnimationPlayer as AnimationPlayer
@onready var chase_timer := $chase_timer as Timer

func _ready():
	chase_timer.timeout.connect(on_timer_timeout )

func _physics_process(delta: float) -> void:
	if _state != State.DEAD and _state != State.DYING:
		handle_vision()
		
		if _state == State.WANDER:
			if velocity.is_zero_approx():
				speed = wander_speed
			elif velocity.x == chase_speed:
				speed = wander_speed
			elif velocity.x == -chase_speed:
				speed = -wander_speed
			if not floor_detector_left.is_colliding():
				speed = wander_speed
			elif not floor_detector_right.is_colliding():
				speed = -wander_speed
		elif _state == State.CHASE:
			if last_known_player_location.x > position.x:
				speed = chase_speed
			elif last_known_player_location.x < position.x:
				speed = -chase_speed
		
		velocity.x = speed
		
		if is_on_wall():
			velocity.x = -velocity.x

		if velocity.x > 0.0:
			sprite.scale.x = abs(sprite.scale.x)
			player_detection_front.scale.x = player_detection_front.scale.x
			player_detection_rear.scale.x = player_detection_rear.scale.x
		elif velocity.x < 0.0:
			sprite.scale.x = -1*abs(sprite.scale.x)
			player_detection_front.scale.x = -player_detection_front.scale.x
			player_detection_rear.scale.x = -player_detection_rear.scale.x

		var animation := get_new_animation()
		if animation != animation_player.current_animation:
			animation_player.play(animation)
			
		velocity.y += gravity * delta
		move_and_slide()

func handle_vision():
	if player_detection_front.is_colliding():
		player_found = true
		_state = State.CHASE
		chase_timer.start(1)
		last_known_player_location = player_detection_front.get_collision_point()
	elif player_detection_rear.is_colliding():
		player_found = true
		_state = State.CHASE
		chase_timer.start(1)
		last_known_player_location = player_detection_rear.get_collision_point()
	else:
		player_found = false 

func reduce_health(damage) -> void:
	health -= damage
	update_health()

func update_health() -> void:
	if health <= 0:
		_state = State.DYING
		velocity = Vector2.ZERO
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

func on_timer_timeout() -> void:
	if player_found == false:
		_state = State.WANDER 

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "destroy()":
		_state = State.DEAD
		
