class_name Player extends CharacterBody3D

signal coin_collected()
signal cancel_melee(mandatory : bool)

const WALK_SPEED = 10.0
const DASH_SPEED = 40.0
const ACCELERATION_SPEED = WALK_SPEED * 6.0
const JUMP_VELOCITY = 20.0
const WALL_JUMP_VERTICAL_VELOCITY = 30.0
const WALL_JUMP_HORIZONTAL_VELOCITY = 20.0
## Maximum speed at which the player can fall.
const TERMINAL_VELOCITY = 20
const WALL_TERMINAL_VELOCITY = 5

## The player listens for input actions appended with this suffix.[br]
## Used to separate controls for multiple players in splitscreen.
@export var action_suffix := ""

@export_group("Consts")
@export var health : float = 20.0
@export_group("Verbs")
@export var can_double_jump : bool = true
@export var can_wall_jump : bool = true
@export var can_dash : bool = true
@export var has_egg : bool = false

#var sprite_scale =
var friction : float = 0.5
var gravity : int = -5*ProjectSettings.get("physics/3d/default_gravity")
var near_egg = false
var world_egg

#child nodes
@onready var platform_detector := $PlatformDetector as RayCast3D
@onready var animation_player := $AnimationPlayer as AnimationPlayer
@onready var shoot_timer := $ShootAnimation as Timer
@onready var dash_timer := $dash_timer as Timer
@onready var post_death_timer := $post_death_timer as Timer
@onready var sprite := $Sprite3D as Sprite3D
@onready var first_jump_sound := $first_jump as AudioStreamPlayer3D
@onready var second_jump_sound := $second_jump as AudioStreamPlayer3D
@onready var dash_sound := $dash as AudioStreamPlayer3D
@onready var camera := $Camera as Camera3D
@onready var hitbox := $Sprite2D/Hitbox as Area3D
@onready var melee_attack := $Sprite3D/melee_attack as Node3D
@onready var jump_cloud := $jump_cloud as CPUParticles3D
@onready var step_particles := $step_particles as CPUParticles3D
@onready var player_egg := $player_egg as MeshInstance3D

@onready var gun = sprite.get_node(^"Gun") as Gun
@onready var hit_particles := $Sprite3D/blood_cloud

#state variables
var _double_jump_charged := false
var _dash_charged
var _is_dashing
var _meleeing : bool = false
var _wall_jumping : bool = false
var _dying : bool = false


func _ready():
	pass

func _physics_process(delta: float) -> void:
	if _dying == true:
		return
	# jumping logic
	_wall_jumping = false
	velocity.z = 0
	position.z = 0
	if not _meleeing:
		if is_on_floor():
			_double_jump_charged = true
			_dash_charged = true
			_is_dashing = false
		if is_on_wall():
			_double_jump_charged = true
			_dash_charged = true
			_is_dashing = false
		if Input.is_action_just_pressed("jump" + action_suffix):
			try_jump()
		elif Input.is_action_just_released("jump" + action_suffix) and velocity.y < 0.0:
			# The player let go of jump early, reduce vertical momentum.
			velocity.y *= 0.6
	# dashing logic
		if Input.is_action_just_pressed("dash" + action_suffix) and _dash_charged:
			_is_dashing = true
			_dash_charged = false
			try_dash()
	
	# Fall.
	if is_on_wall_only():
		if _wall_jumping:
			velocity.y = minf(TERMINAL_VELOCITY, velocity.y + gravity * delta)
		else:
			velocity.y = -WALL_TERMINAL_VELOCITY
	else:
		if (_is_dashing):
			velocity.y = 0
		else:
			velocity.y = minf(TERMINAL_VELOCITY, velocity.y + gravity * delta)
	

	var direction := Input.get_axis("move_left" + action_suffix, "move_right" + action_suffix) * WALK_SPEED
	if is_on_floor() and direction == 0:
		velocity.x = move_toward(velocity.x, direction, ACCELERATION_SPEED * delta) * (1-friction)
	else:
		velocity.x = move_toward(velocity.x, direction, ACCELERATION_SPEED * delta)


	if not is_zero_approx(velocity.x):
		if velocity.x > 0.0:
			sprite.scale.x = -1*abs(sprite.scale.x)
			player_egg.position.x = -1*abs(player_egg.position.x)
			player_egg.rotation.z = 9.7
		else:
			sprite.scale.x = abs(sprite.scale.x)
			player_egg.position.x = abs(player_egg.position.x)
			player_egg.rotation.z = -9.7

	#floor_stop_on_slope = not platform_detector.is_colliding()
	move_and_slide()

	var is_shooting := false
	#if Input.is_action_just_pressed("shoot" + action_suffix):
		#is_shooting = gun.shoot(sprite.scale.x)

	var animation := get_new_animation(false)
	if animation != animation_player.current_animation and !_meleeing:
		#if is_shooting:
			#shoot_timer.start()
		animation_player.play(animation)

	if Input.is_action_just_pressed("melee" + action_suffix):
		if not _meleeing:
			_meleeing = true
			melee_attack.attack()
	if Input.is_action_just_pressed("spike_egg" + action_suffix):
		if (has_egg):
			spike_egg()

func get_new_animation(is_shooting := false) -> String:
	var animation_new: String
	step_particles.emitting = false
	if health <= 0:
		animation_new = "falling"
	elif is_on_floor():
		if absf(velocity.x) > 0:
			animation_new = "run"
			step_particles.emitting = true
		else:
			animation_new = "idle"
			
	elif _is_dashing:
		animation_new = "dash"
	else:
		if velocity.y < 0.0:
			animation_new = "falling"
		else:
			animation_new = "jumping"
	if is_shooting:
		animation_new += "_weapon"
	return animation_new

func try_dash() -> void:
	if can_dash:
		velocity.x = -DASH_SPEED * sprite.scale.x
		dash_sound.play()
		_dash_charged = false
		dash_timer.start()
		jump_cloud.emitting = true

func try_jump() -> void:
	if is_on_floor():
		first_jump_sound.play()
		velocity.y = JUMP_VELOCITY
		_wall_jumping = false
		jump_cloud.emitting = true
	elif is_on_wall() and can_wall_jump:
		velocity.x = sign(sprite.scale.x)*WALL_JUMP_HORIZONTAL_VELOCITY
		velocity.y = 100 # why isnt this working?
		_wall_jumping = true
		first_jump_sound.play()
		jump_cloud.emitting = true
	elif _double_jump_charged and can_double_jump and not has_egg:
		velocity.y = JUMP_VELOCITY
		_double_jump_charged = false
		second_jump_sound.play()
		if (_is_dashing):
			_is_dashing = false
		_wall_jumping = false
		jump_cloud.emitting = true
		#velocity.x *= 2.5
	else:
		return

func damage(damage_amount):
	health -= damage_amount
	cancel_melee.emit(false)
	hit_particles.emitting = true;
	print("player health:", health)
	if health <= 0:
		kill()
		

func kill():
	# player dies	
	# start the timer until the level is reloaded
	print("kill")
	_dying = true
	cancel_melee.emit(true)
	post_death_timer.start()

func take_egg():
	player_egg.visible = true
	world_egg.visible = false
	world_egg.freeze = true
	has_egg = true
	

func drop_egg():
	# player drops egg
	world_egg.position.x = position.x
	world_egg.position.y = position.y
	world_egg.linear_velocity.x = velocity.x
	world_egg.linear_velocity.y = velocity.y
	world_egg.rotation.z = 0
	world_egg.visible = true
	world_egg.freeze = false
	player_egg.visible = false
	has_egg = false
	
func spike_egg():
	# spikes the egg vertically downwards as an attack
	world_egg.position.x = position.x
	world_egg.position.y = position.y
	world_egg.linear_velocity.x = 0
	world_egg.linear_velocity.y = -30
	world_egg.rotation.z = 0
	world_egg.visible = true
	world_egg.freeze = false
	player_egg.visible = false
	has_egg = false
	first_jump_sound.play()
	velocity.y = JUMP_VELOCITY

func _on_dash_timer_timeout():
	_is_dashing = false
	
func _input(event: InputEvent):
	if event is InputEventKey and event.keycode == KEY_ENTER and event.pressed:
		print("ENTER PRESSED")
		if near_egg and not has_egg:
			print("TAKING EGG")
			take_egg()
		elif has_egg:
			print("Dropping egg")
			drop_egg()


func _on_interaction_bounds_area_entered(area):
	if area.get_parent().is_in_group("npcs"):
		var NPC = area.get_parent().name
		Global.currently_interactable_NPC = NPC
	elif area.get_parent().is_in_group("traps"):
		damage(100)
	elif area.get_parent().is_in_group("egg"):
		print("NEAR EGG")
		near_egg = true
		world_egg = area.get_parent()


func _on_interaction_bounds_area_exited(area):
	if area.get_parent().is_in_group("npcs"):
		var NPC = area.get_parent().name
		if NPC == Global.currently_interactable_NPC:
			Global.currently_interactable_NPC = ""
	elif area.get_parent().is_in_group("egg"):
		near_egg = false


func _on_post_death_timer_timeout():
	# player has dies, post death timer has elapsed, reset the level
	game_script.reset_level()


func _on_melee_attack_meleeing(active):
	if active:
		_meleeing = true
	else:
		_meleeing = false
