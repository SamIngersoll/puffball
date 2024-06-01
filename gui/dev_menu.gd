extends Control
var dev_menu_entry = preload("res://gui/dev_menu_entry.tscn")

# var instance = dev_menu_entry.instantiate().with_data(data)
#	add_child(instance)

# Called when the node enters the scene tree for the first time.
func _ready():
	for val in EngineTweakable.val:
		pass
	hide() # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func open():
	show()

func close():
	hide()
