extends Node3D

@export var stiffness : float = 20
@export var mass : float = 1
@export var enable_upward_motion = 1

var timestep = 0.001

var rest_position : Vector3
var current_position : Vector3
var disturbance_force : Vector3 = Vector3(0,0,0)

var particle_emitter : CPUParticles3D
var ik_target_pos : Marker3D
var jiggle_collision_area : CollisionShape3D
# Called when the node enters the scene tree for the first time.
func _ready():	
	particle_emitter = $Marker3D/jump_cloud
	ik_target_pos = $Marker3D
	jiggle_collision_area = $Marker3D/Area3D/CollisionShape3D
	rest_position = ik_target_pos.global_transform.origin
	current_position = ik_target_pos.global_transform.origin

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var restoring_force = stiffness *  (rest_position - current_position)
	ik_target_pos.global_transform.origin += (timestep * (restoring_force - disturbance_force))/mass
	current_position = ik_target_pos.global_transform.origin


func _on_area_3d_body_entered(body):
	if (body.is_in_group("player")):
		
		var btwn = jiggle_collision_area.global_transform.origin - body.global_transform.origin
		#btwn.z = 0
		disturbance_force = btwn
		disturbance_force.x *= 0
		disturbance_force.z *= 0
		if (body.global_transform.origin.y > jiggle_collision_area.global_transform.origin.y):
			disturbance_force.y = abs(disturbance_force.y) * 100
			print("player entered")
		else:
			if (enable_upward_motion):
				disturbance_force.y = abs(disturbance_force.y) * -100
		
		particle_emitter.emitting = true
	else:
		disturbance_force = Vector3(0,0,0)

func _on_area_3d_body_exited(body):
	disturbance_force = Vector3(0,0,0)
