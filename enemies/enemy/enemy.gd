class_name Enemy extends CharacterBody3D


enum State {
	IDLE,
	WANDER,
	CHASE,
	AGGRO,
	ATTACK,
	DYING,
	DEAD
}


@export var max_health = 20 as float
var health : float
@export var default_state = State.WANDER
@export var chase_time = 3.0 as float
@export var attack_cooldown : float = 4.0
@export var attack_range = 2.0 as float
@export var wander_speed = 2.0 as float
@export var chase_speed = 6.0 as float

var speed = wander_speed
var _state : State
var last_known_player_location : Vector3
var _can_attack : bool = true

@onready var gravity: int = ProjectSettings.get("physics/3d/default_gravity")

@onready var floor_detector_front := $raycast_floor_detector/FloorDetectorFront as RayCast3D
@onready var wall_detector_front := $raycast_wall_detector/WallDetectorFront as RayCast3D
@onready var player_detector_front := $raycast_player_detector/PlayerDetectorFront as RayCast3D
@onready var player_detector_rear := $raycast_player_detector/PlayerDetectorRear as RayCast3D

@onready var sprite := $Sprite3D as Sprite3D
@onready var animation_player := $AnimationPlayer as AnimationPlayer
@onready var chase_timer := $chase_timer as Timer

@onready var melee_attack := $Sprite3D/melee_attack
@onready var hit_particles := $Sprite3D/blood_cloud
@onready var hit_sound := $Hit
@onready var melee_cooldown_timer := $melee_cooldown_timer
signal cancel_melee(mandatory : bool)

func _ready():
	velocity.x = wander_speed * sign(sprite.scale.x)
	_state = default_state
	health = max_health

func _physics_process(delta: float) -> void:
	if _state != State.DEAD and _state != State.DYING:
		if _state == State.IDLE:
			speed = 0
		elif _state == State.WANDER:
			speed = wander_speed
		elif _state == State.CHASE:
			if not floor_detector_front.is_colliding():
				speed = 0
			else:
				speed = chase_speed
		# any stage of attacking
		elif (_state == State.ATTACK):
			speed = 0
			
		velocity.x = speed * sign(sprite.scale.x)

		handle_vision()

		var animation := get_new_animation()
		if animation != animation_player.current_animation:
			animation_player.play(animation)
			
		velocity.y -= gravity * delta
		velocity.z = 0
		position.z = 0
		move_and_slide()

func handle_vision():
	#print("state:", _state)
	
	var need_to_turn = false
	if wall_detector_front.is_colliding() and _state != State.CHASE:
		#print("COLLIDING FRONT")
		need_to_turn = true
	if not floor_detector_front.is_colliding() and _state != State.CHASE:
		#print("FLOOR NOT COLLIDING FRONT")
		need_to_turn = true
	if player_detector_front.is_colliding():
		#print("player detected FRONT")
		chase_timer.start(chase_time)
		# this block describes which states CANNOT transition to chasing
		# all other blocks will transition to chasing
		if (_state == State.WANDER) || (_state == State.IDLE):
			_state = State.CHASE
		var player_position = player_detector_front.get_collision_point()
		last_known_player_location = player_position
		#print("distance:", player_position.x - position.x, "spacing:", melee_attack.transform.basis.x.x)
		# if the player is in attack range and we are currently chasing 
		# (e.g. not already attacking), then transition to attacking
		if (abs(player_position.x - position.x) <= melee_attack.transform.basis.x.x
			and _state==State.CHASE):
			
			_state = State.AGGRO
			
		if (_state == State.AGGRO):
			if (abs(player_position.x - position.x) >= melee_attack.transform.basis.x.x):
				_state = State.CHASE
			
			elif (abs(player_position.x - position.x) <= (melee_attack.transform.basis.x.x - 0.5)):
				velocity.x = -(chase_speed/2.0)*sign(player_position.x - position.x)
			else:
				velocity.x = 0
			print("velocity.x", velocity.x)
			
			if(_can_attack):
				if (0.5 >= randf_range(0,1)):
					_state = State.ATTACK
					melee_attack.attack()
					melee_cooldown_timer.start(attack_cooldown)
					_can_attack = false
			
		#if (_state == State.ATTACK):
			
			#_state = State.AGGRO
			
		need_to_turn = false
	# if the player is behind us and we arent attacking (cant turn while attacking)
	elif player_detector_rear.is_colliding() and _state != State.ATTACK:
		#print("player detection REAR")
		_state = State.CHASE
		chase_timer.start(chase_time)
		last_known_player_location = player_detector_rear.get_collision_point()
		need_to_turn = true
	if need_to_turn:
		# cannot turn while attacking (before this it was turning mid attack if you jumped)
		if (_state != State.ATTACK):
			turn_around()

func turn_around() -> void:
	# I think flipping the root node is buggy so instead we flip all the children individually
	sprite.scale.x = -1*(sprite.scale.x)
	velocity.x = -1*(velocity.x)
	wall_detector_front.target_position.x = -1*wall_detector_front.target_position.x
	floor_detector_front.position.x = -1*floor_detector_front.position.x
	player_detector_front.scale.x = -player_detector_front.scale.x
	player_detector_rear.scale.x = -player_detector_rear.scale.x

func damage(damage_amount):
	health -= damage_amount
	print("ENEMY IS DAMAGED")
	update_health()
	hit_particles.emitting = true;


func update_health():
	if health <= 0:
		cancel_melee.emit(true)
		_state = State.DYING
		velocity = Vector3.ZERO
		animation_player.play(&"destroy")
	else:
		hit_sound.play()
		cancel_melee.emit(false)

func get_new_animation() -> StringName:
	var animation_new: StringName
	if _state == State.IDLE:
		animation_new = &"idle"
	elif _state == State.WANDER:
		animation_new = &"walk"
	elif _state == State.AGGRO:
		animation_new = &"idle"
	elif _state == State.CHASE:
		if velocity.is_zero_approx():
			animation_new = &"idle"
		else:
			animation_new = &"walk"
	elif _state == State.ATTACK:
		# melee_attack.gd script takes care of attack animations
		pass
	elif _state == State.DYING:
		pass
	else:
		self.queue_free() # Replace with function body.
	return animation_new

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "destroy":
		_state = State.DEAD

func _on_chase_timer_timeout():
	print("TIMEOUT")
	_state = State.WANDER 

func _on_melee_attack_meleeing(active):
	if active:
		_state = State.ATTACK
	else:
		_state = State.AGGRO


func _on_melee_cooldown_timer_timeout() -> void:
	_can_attack = true
	pass # Replace with function body.
