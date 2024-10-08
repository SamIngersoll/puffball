class_name Player extends CharacterBody2D


signal coin_collected()

const WALK_SPEED = 300.0
const DASH_SPEED = 3200.0
const ACCELERATION_SPEED = WALK_SPEED * 6.0
const JUMP_VELOCITY = -800.0
const WALL_JUMP_HORIZONTAL_VELOCITY = 500.0
## Maximum speed at which the player can fall.
const TERMINAL_VELOCITY = 700
const WALL_TERMINAL_VELOCITY = 250

## The player listens for input actions appended with this suffix.[br]
## Used to separate controls for multiple players in splitscreen.
@export var action_suffix := ""

@export_group("Consts")
@export var health : float = 20.0
@export_group("Verbs")
@export var can_double_jump : bool = true
@export var can_wall_jump : bool = true
@export var can_dash : bool = true

#var sprite_scale =
var friction : float = 0.5
var gravity : int = ProjectSettings.get("physics/2d/default_gravity")

#child nodes
@onready var platform_detector := $PlatformDetector as RayCast2D
@onready var animation_player := $AnimationPlayer as AnimationPlayer
@onready var shoot_timer := $ShootAnimation as Timer
@onready var sprite := $Sprite2D as Sprite2D
@onready var first_jump_sound := $first_jump as AudioStreamPlayer2D
@onready var second_jump_sound := $second_jump as AudioStreamPlayer2D
@onready var dash_sound := $dash as AudioStreamPlayer2D
@onready var gun = sprite.get_node(^"Gun") as Gun
@onready var camera := $Camera as Camera2D
@onready var hitbox := $Sprite2D/Hitbox as Area2D
@onready var melee_attack := $Sprite2D/melee_attack as Node2D


# melee attack animation state machine
enum Melee_States {INACTIVE, WINDUP, ACTIVE, RECOVERY}
var _melee_state : int = Melee_States.INACTIVE

# melee attack event times (in animation frames)
  # it is assumed that windeup starts on first frame of animation.
@export var melee_active_begin_frame : int = 2
@export var melee_recovery_begin_frame : int = 3

#state variables
var _double_jump_charged := false
var _dash_charged
var _is_dashing
var _meleeing : bool = false


func _ready():
	pass

func _physics_process(delta: float) -> void:
	# jumping logic
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
	if is_on_wall():
		velocity.y = minf(WALL_TERMINAL_VELOCITY, velocity.y + gravity * delta)
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
		else:
			sprite.scale.x = abs(sprite.scale.x)

	floor_stop_on_slope = not platform_detector.is_colliding()
	move_and_slide()

	var is_shooting := false
	if Input.is_action_just_pressed("shoot" + action_suffix):
		is_shooting = gun.shoot(sprite.scale.x)

	var animation := get_new_animation(is_shooting)
	if animation != animation_player.current_animation and shoot_timer.is_stopped() and !_meleeing:
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
		velocity.x = -DASH_SPEED * sprite.scale.x
		dash_sound.play()
		velocity.y = -150
		_dash_charged = false

func try_jump() -> void:
	if is_on_floor():
		first_jump_sound.play()
	elif is_on_wall() and can_wall_jump:
		velocity.y = JUMP_VELOCITY
		velocity.x = sign(sprite.scale.x)*WALL_JUMP_HORIZONTAL_VELOCITY
		first_jump_sound.play()
	elif _double_jump_charged and can_double_jump:
		_double_jump_charged = false
		second_jump_sound.play()
		#velocity.x *= 2.5
	else:
		return
	velocity.y = JUMP_VELOCITY


func _on_interact_bounds_area_entered(area):
	if area.get_parent().is_in_group("npcs"):
		var NPC = area.get_parent().name
		Global.currently_interactable_NPC = NPC
	elif area.get_parent().is_in_group("traps"):
		damage(100)


func _on_interact_bounds_area_exited(area):
	var NPC = area.get_parent().name
	if NPC == Global.currently_interactable_NPC:
		Global.currently_interactable_NPC = ""


func _on_melee_attack_hit(body):
	if body is Enemy:
		(body as Enemy).reduce_health(BalanceTable.val["melee1_damage"])


func _on_melee_attack_meleeing(active):
	#print("meleeing ", active)
	_meleeing = active
	if active:
		_melee_state = Melee_States.WINDUP
		animation_player.play("melee_windup")
	else:
		_melee_state = Melee_States.INACTIVE

func _on_melee_attack_next_phase():
	if _melee_state == Melee_States.WINDUP:
		_melee_state = Melee_States.ACTIVE
		animation_player.play("melee_active")
	elif _melee_state == Melee_States.ACTIVE:
		_melee_state = Melee_States.RECOVERY
		animation_player.play("melee_recovery")

func damage(damage):
	health -= damage
	if health <= 0:
		kill()
		
func kill():
	get_tree().reload_current_scene()

