extends Node2D

## this variable holds the destination of the level exit. The destination is a string which is the name of the level scene file
@export var destination : String = "tutorial"

signal take_exit(destination)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_area_2d_area_entered(area):
	print("ENTERED")
	if area.get_parent().is_in_group("player"):
		print("ISPLAYER ENTERED")
		get_tree().current_scene.change_level(destination)
