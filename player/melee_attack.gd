extends Node2D

# Must assign these
# Melee timer will be used to handle windup, cooldown, etc
@export var hitbox : Area2D
@export var melee_timer : Timer


var _is_meleeing : bool = false
@export var windup_val : float = 1.0
@export var active_val : float = 2.0
@export var follow_val : float = 0.5

signal hit(body)
signal meleeing(active : bool)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func melee():
	meleeing.emit(true)
	melee_timer.start(windup_val)
	await melee_timer.timeout
	
	hitbox.monitoring = true
	melee_timer.start(active_val)
	await melee_timer.timeout
	hitbox.monitoring = false
	
	melee_timer.start(follow_val)
	await melee_timer.timeout
	meleeing.emit(false)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	pass

func _on_hitbox_body_entered(body):
	print("hit: ", body)
	hit.emit(body)
	pass # Replace with function body.
