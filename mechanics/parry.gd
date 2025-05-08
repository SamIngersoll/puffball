extends Node3D

enum DebugDisplay {NONE, PARRY_FRAMES}

# Must assign these
# Make sure the monitors the attack layer, and enemy attack hitboxes are in the
# attack layer

@export_group("Required Child Nodes")
@export var parrybox : Area3D
@export var parry_timer : Timer

@export_group("Debugging")
@export var debug_poly : MeshInstance3D
## Choose what to represent with the debug polygon
@export var debug_draw : DebugDisplay = DebugDisplay.NONE

@export var parry_frames_start_val : float = 0.2
@export var parry_frames_duration_val : float = 0.4

var _parrying : bool = false

signal parrying(active : bool)
signal parry_hit(body)

# Called when the node enters the scene tree for the first time.
func _ready():
	debug_poly.hide()

func parry():
	# start parry frames
	_parrying = true
	parrying.emit(_parrying)

	# start parry windup frames
	if debug_draw == DebugDisplay.PARRY_FRAMES:
		debug_poly.mesh.material.albedo_color = Color("e5f04a")
		debug_poly.show()

	parry_timer.start(parry_frames_start_val)
	await parry_timer.timeout

	# start active parry frames
	parrybox.monitoring = true

	if debug_draw == DebugDisplay.PARRY_FRAMES:
		debug_poly.mesh.material.albedo_color = Color("e01451")

	parry_timer.start(parry_frames_duration_val)
	await parry_timer.timeout

	# end parry frames
	if debug_draw == DebugDisplay.PARRY_FRAMES:
		debug_poly.hide()

	parrybox.monitoring = false
	_parrying = false
	parrying.emit(_parrying)

# Called /every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	pass

func _on_parrybox_body_entered(body):
	# print("hit: ", body)
	body.parried()
	pass # Replace with function body.
