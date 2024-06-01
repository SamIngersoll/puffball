class_name Player extends CharacterBody2D


signal coin_collected()

const WALK_SPEED = 300.0
const ACCELERATION_SPEED = WALK_SPEED * 6.0
const JUMP_VELOCITY = -725.0
## Maximum speed at which the player can fall.
const TERMINAL_VELOCITY = 700

## The player listens for input actions appended with this suffix.[br]
## Used to separate controls for multiple players in splitscreen.
@export var action_suffix := ""

@export_group("Verbs")
@export var can_double_jump : bool = true
@export var can_dash : bool = true

#var sprite_scale =
var friction : float = 0.5
var gravity : int = ProjectSettings.get("physics/2d/default_gravity")

#child nodes
@onready var platform_detector := $PlatformDetector as RayCast2D
@onready var animation_player := $AnimationPlayer as AnimationPlayer
@onready var shoot_timer := $ShootAnimation as Timer
@onready var sprite := $Sprite2D as Sprite2D
@onready var jump_sound := $Jump as AudioStreamPlayer2D
@onready var gun = sprite.get_node(^"Gun") as Gun
@onready var camera := $Camera as Camera2D
@onready var hitbox := $Sprite2D/Hitbox as Area2D
@onready var melee_timer := $MeleeAnimation as Timer
@onready var melee_attack := $Sprite2D/melee_attack as Node2D

#state variables
var _double_jump_charged := false
var _dash_charged
var _is_dashing
var _meleeing := false


func _ready():
	pass

func _physics_process(delta: float) -> void:
	# jumping logic
	if is_on_floor():
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
	velocity.y = minf(TERMINAL_VELOCITY, velocity.y + gravity * delta)

	var direction := Input.get_axis("move_left" + action_suffix, "move_right" + action_suffix) * WALK_SPEED
	if is_on_floor() and direction == 0:
		velocity.x = move_toward(velocity.x, direction, ACCELERATION_SPEED * delta) * (1-friction)
	else:
		velocity.x = move_toward(velocity.x, direction, ACCELERATION_SPEED * delta)


	if not is_zero_approx(velocity.x):
		if velocity.x > 0.0:
			sprite.scale.x = -1*abs(sprite.scale.x)
		else:
			sprite.scale.x = abs(sprite.scale.x)

	floor_stop_on_slope = not platform_detector.is_colliding()
	move_and_slide()

	var is_shooting := false
	if Input.is_action_just_pressed("shoot" + action_suffix):
		is_shooting = gun.shoot(sprite.scale.x)

	var animation := get_new_animation(is_shooting)
	if animation != animation_player.current_animation and shoot_timer.is_stopped():
		if is_shooting:
			shoot_timer.start()
		animation_player.play(animation)

	if Input.is_action_just_pressed("melee" + action_suffix):
		if not _meleeing:
			melee_attack.melee()

func get_new_animation(is_shooting := false) -> String:
	var animation_new: String
	if is_on_floor():
		if absf(velocity.x) > 0.1:
			animation_new = "run"
		else:
			animation_new = "idle"
	elif _is_dashing:
		animation_new = "dash"
	else:
		if velocity.y > 0.0:
			animation_new = "falling"
		else:
			animation_new = "jumping"
	if is_shooting:
		animation_new += "_weapon"
	return animation_new

func try_dash() -> void:
	if can_dash:
		velocity.x = -1200 * sprite.scale.x
		jump_sound.pitch_scale = 3
		jump_sound.play()
		velocity.y = -150
		_dash_charged = false

func try_jump() -> void:
	if is_on_floor():
		jump_sound.pitch_scale = 1.0
	elif _double_jump_charged and can_double_jump:
		_double_jump_charged = false
		velocity.x *= 2.5
		jump_sound.pitch_scale = 1.5
	else:
		return
	velocity.y = JUMP_VELOCITY
	jump_sound.play()


func _on_interact_bounds_area_entered(area):
	var NPC = area.get_parent().name
	Global.currently_interactable_NPC = NPC

func _on_interact_bounds_area_exited(area):
	var NPC = area.get_parent().name
	if NPC == Global.currently_interactable_NPC:
		Global.currently_interactable_NPC = ""



func _on_melee_attack_hit(body):
	if body is Enemy:
		(body as Enemy).reduce_health(11)



func _on_melee_attack_meleeing(active):
	#print("meleeing ", active)
	_meleeing = active
