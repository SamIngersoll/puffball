extends Node3D

@export var damage_dealt : float = 10

func _on_area_3d_body_entered(body) -> void:
	body.damage(damage_dealt)

# semi-janky workaround using an area because the enemy wasnt working otherwise
func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.owner.is_in_group("enemies"):
		area.owner.damage(damage_dealt)
