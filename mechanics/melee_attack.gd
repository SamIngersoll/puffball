extends Node3D

enum DebugDisplay {NONE, MELEE_FRAMES, PARRIABLE_FRAMES}
# idea: can also make a debug timer and set the timer length
# based on the DebugDisplay enum to decouple debug code from
# the melee/parry code

enum MeleeState {IDLE, WINDUP, ACTIVE, RECOVERY}
enum ParriableState {IDLE, WINDUP, ACTIVE}
enum Msg {NONE, START, CANCEL}

# Must assign these
# Melee timer will be used to handle windup, cooldown, etc

@export_group("Required Child Nodes")
@export var hitbox : Area3D
@export var melee_timer : Timer
@export var parriable_timer : Timer
## Animation Player which has the attack animations in it
@export var animation_player : AnimationPlayer

@export_group("Debugging")
@export var debug_poly : MeshInstance3D
## Choose what to represent with the debug polygon
@export var debug_draw : DebugDisplay = DebugDisplay.NONE

# initial data based on dark souls straight sword R1
## These need to be the exact names of the attack animations in the animation player
@export_group("Melee Attack Animations")
## Exact name of the windup animation in the Animation Player
@export var windup_anim : String = "melee_windup"
## Exact name of the attack animation in the Animation Player
@export var active_anim : String = "melee_attack"
## Exact name of the recovery animation in the Animation Player
@export var recovery_anim : String = "melee_recovery"

## indicates if THIS atttack/character is parriable
@export var is_parriable : bool = false
@export var parriable_frames_start_val : String = "parriable1_windup"
@export var parriable_frames_duration_val : String = "parriable1_duration"
# From a design standpoint, probably want the parriable frames
# to start before the damage frames start

@export_group("Optional Child Nodes")
@export var _hit_particles : CPUParticles3D

var _meleeing : bool = false
var _parriable : bool = false
var _melee_state : MeleeState = MeleeState.IDLE
var _parriable_state : ParriableState = ParriableState.IDLE
var _message : Msg = Msg.NONE



signal hit(body)
signal meleeing(active : bool)
signal parriable(active : bool)

# Called when the node enters the scene tree for the first time.
func _ready():
	debug_poly.hide()

# TODO See if you need self.set_deferred("_message", Msg.START)
func attack():
	#print("[melee attack] attack")
	_message = Msg.START

func parried():
	_message = Msg.CANCEL

func cancel_melee():
	melee_timer.stop()
	_meleeing = false
	hitbox.monitoring = false
	#if hitbox.monitoring:
		#hitbox.set_deferred("monitoring", false)

	if is_parriable:
		parriable_timer.stop()
		_parriable = false

	if debug_draw != DebugDisplay.NONE:
		debug_poly.hide()

#region Parriable functions
func start_parriable_windup_frames():
	if not is_parriable:
		return

	# start parriable windup frames
	if debug_draw == DebugDisplay.PARRIABLE_FRAMES:
		debug_poly.color = Color("e5f04a")
		debug_poly.show()

	parriable_timer.start(EngineTweakable.val[parriable_frames_start_val])
	_parriable_state = ParriableState.WINDUP
	

func start_parriable_active_frames():
	# start parriable frames
	_parriable = true
	
	parriable.emit(_parriable)

	if debug_draw == DebugDisplay.PARRIABLE_FRAMES:
		debug_poly.color = Color("e01451")

	parriable_timer.start(EngineTweakable.val[parriable_frames_duration_val])
	_parriable_state = ParriableState.ACTIVE

func finish_parriable_frames():
	# end parriable frames
	if debug_draw == DebugDisplay.PARRIABLE_FRAMES:
		debug_poly.hide()

	_parriable = false
	parriable.emit(_parriable)
	_parriable_state = ParriableState.IDLE
#endregion

#region melee functions
func start_melee_windup_frames():
	# Start meleeing
	_meleeing = true
	meleeing.emit(_meleeing)
	hitbox.monitoring = false
	
	# Start the melee windup timer
	if debug_draw == DebugDisplay.MELEE_FRAMES:
		debug_poly.mesh.material.albedo_color = Color("e5f04a")
		debug_poly.show()

	melee_timer.start(EngineTweakable.val[windup_anim])
	_melee_state = MeleeState.WINDUP
	
	animation_player.play(windup_anim)

func start_melee_active_frames():
	hitbox.monitoring = true
	# Start the active time
	if debug_draw == DebugDisplay.MELEE_FRAMES:
		debug_poly.mesh.material.albedo_color = Color("e01451")

	#hitbox.set_deferred("monitoring", true)
	melee_timer.start(EngineTweakable.val[active_anim])
	_melee_state = MeleeState.ACTIVE
	
	animation_player.play(active_anim)

func start_melee_recovery_frames():
	# Enter follow through
	hitbox.monitoring = false
	
	if debug_draw == DebugDisplay.MELEE_FRAMES:
		debug_poly.mesh.material.albedo_color = Color("58b0f6")

	#hitbox.set_deferred("monitoring", false)
	melee_timer.start(EngineTweakable.val[recovery_anim])
	_melee_state = MeleeState.RECOVERY

	animation_player.play(recovery_anim)
	
func finish_melee_frames():
	# End meleeing
	if debug_draw == DebugDisplay.MELEE_FRAMES:
		debug_poly.hide()

	_meleeing = false
	meleeing.emit(_meleeing)
	_melee_state = MeleeState.IDLE
#endregion

# Called /every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	match _message:
		Msg.NONE:
			pass

		Msg.START:
			start_melee_windup_frames()
			start_parriable_windup_frames()

		Msg.CANCEL:
			cancel_melee()
			# can also check for particular state to prevent cancel
			# or add another timer for an uncancellable time

	_message = Msg.NONE

func _on_hitbox_body_entered(body):
	print("hit: ", body)
	hit.emit(body)
	_hit_particles.emitting = true

func _on_parriable_timer_timeout():
	match _parriable_state:
		ParriableState.WINDUP:
			start_parriable_active_frames()
		ParriableState.ACTIVE:
			finish_parriable_frames()
		_:
			pass

func _on_melee_timer_timeout():
	match _melee_state:
		MeleeState.WINDUP:
			start_melee_active_frames()
		MeleeState.ACTIVE:
			start_melee_recovery_frames()
		MeleeState.RECOVERY:
			finish_melee_frames()
		_:
			pass
