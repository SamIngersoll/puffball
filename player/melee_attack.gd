extends Node2D

enum DebugDisplay {NONE, MELEE_FRAMES, PARRIABLE_FRAMES}

# Must assign these
# Melee timer will be used to handle windup, cooldown, etc

@export_group("Required Child Nodes")
@export var hitbox : Area2D
@export var melee_timer : Timer
@export var parriable_timer : Timer

@export_group("Debugging")
@export var debug_poly : Polygon2D
## Choose what to represent with the debug polygon
@export var debug_draw : DebugDisplay = DebugDisplay.NONE

# initial data based on dark souls straight sword R1
@export_group("Melee Attack Properties")
@export var windup_val : String = "melee1_windup"
@export var active_val : String = "melee1_attack"
@export var recovery_val : String = "melee1_recovery"

## indicates if THIS atttack/character is parriable
@export var is_parriable : bool = false
@export var parry_frames_start_val : String = "parriable1_windup"
@export var parry_frames_duration_val : String = "parriable1_duration"
# From a design standpoint, probably want the parriable frames 
# to start before the damage frames start

var _meleeing : bool = false
var _parriable : bool = false

signal hit(body)
signal meleeing(active : bool)
signal parriable(active : bool)

# Called when the node enters the scene tree for the first time.
func _ready():
	debug_poly.hide()

func attack():
	set_parriable_frames()
	melee()
	
func set_parriable_frames():
	if not is_parriable:
		return
	
	# start parriable windup frames
	if debug_draw == DebugDisplay.PARRIABLE_FRAMES:
		debug_poly.color = Color("e5f04a")
		debug_poly.show()
		
	parriable_timer.start(EngineTweakable.val[parry_frames_start_val])
	await parriable_timer.timeout
	
	# start parriable frames
	_parriable = true
	parriable.emit(_parriable)
	
	if debug_draw == DebugDisplay.PARRIABLE_FRAMES:
		debug_poly.color = Color("e01451")
	
	parriable_timer.start(EngineTweakable.val[parry_frames_duration_val])
	await parriable_timer.timeout
	
	# end parriable frames
	if debug_draw == DebugDisplay.PARRIABLE_FRAMES:
		debug_poly.hide()
	
	_parriable = true
	parriable.emit(_parriable)
	
func melee():
	# Start meleeing
	_meleeing = true
	meleeing.emit(_meleeing)

	# Start the melee windup timer
	if debug_draw == DebugDisplay.MELEE_FRAMES:
		debug_poly.color = Color("e5f04a")
		debug_poly.show()

	melee_timer.start(EngineTweakable.val[windup_val])
	await melee_timer.timeout

	# Start the active time
	if debug_draw == DebugDisplay.MELEE_FRAMES:
		debug_poly.color = Color("e01451")

	hitbox.monitoring = true
	melee_timer.start(EngineTweakable.val[active_val])
	await melee_timer.timeout

	# Enter follow through
	if debug_draw == DebugDisplay.MELEE_FRAMES:
		debug_poly.color = Color("58b0f6")

	hitbox.monitoring = false
	melee_timer.start(EngineTweakable.val[recovery_val])
	await melee_timer.timeout

	# End meleeing
	if debug_draw == DebugDisplay.MELEE_FRAMES:
		debug_poly.hide()

	_meleeing = false
	meleeing.emit(_meleeing)
	pass

# Called /every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	pass

func _on_hitbox_body_entered(body):
	# print("hit: ", body)
	hit.emit(body)
	pass # Replace with function body.
