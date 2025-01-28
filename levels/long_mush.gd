extends StaticBody3D


var particle_emitter : CPUParticles3D = null

# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		if child is CPUParticles3D:
			particle_emitter = child

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_area_3d_body_entered(body):
	if (body.is_in_group("player")):
		particle_emitter.emitting = true


