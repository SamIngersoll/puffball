extends Node2D

# Must assign these
# Melee timer will be used to handle windup, cooldown, etc
@export var hitbox : Area2D
@export var melee_timer : Timer
@export var debug_poly : Polygon2D
@export var debug_draw : bool = false

var _meleeing : bool = false

# initial data based on dark souls straight sword R1
@export var windup_val : String = "melee1_windup"
@export var active_val : String = "melee1_attack"
@export var recovery_val : String = "melee1_recovery"

signal hit(body)
signal meleeing(active : bool)
signal next_phase()

# Called when the node enters the scene tree for the first time.
func _ready():
	debug_poly.hide()
	pass # Replace with function body.


func melee():
	# Start meleeing
	_meleeing = true
	meleeing.emit(_meleeing)
	
	# Start the melee windup timer
	if debug_draw:
		debug_poly.color = Color("e5f04a")
		debug_poly.show()

	melee_timer.start(EngineTweakable.val[windup_val])
	await melee_timer.timeout


	# Start the active time
	if debug_draw:
		debug_poly.color = Color("e01451")

	# tell the player to transistion to the attacking phase
	next_phase.emit()

	hitbox.monitoring = true
	melee_timer.start(EngineTweakable.val[active_val])
	await melee_timer.timeout

	# Enter follow through
	if debug_draw:
		debug_poly.color = Color("58b0f6")

	# tell the player to transistion to the following through phase
	next_phase.emit()

	hitbox.monitoring = false
	melee_timer.start(EngineTweakable.val[recovery_val])
	await melee_timer.timeout

	# End meleeing
	if debug_draw:
		debug_poly.hide()

	_meleeing = false
	meleeing.emit(_meleeing)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	pass

func _on_hitbox_body_entered(body):
	# print("hit: ", body)
	hit.emit(body)
	pass # Replace with function body.
