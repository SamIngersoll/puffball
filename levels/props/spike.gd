extends Node3D

@export var damage_dealt : float = 10

func _on_area_3d_body_entered(body: Node3D) -> void:
	print("BODDYYYYYY", body)
	body.damage(damage_dealt)
