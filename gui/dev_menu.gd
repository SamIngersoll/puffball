extends Control
# dev menu entry can be used to instantiate and change any of the 
# singletons, provided they have a dict stored in the '.val' field
var dev_menu_entry = preload("res://gui/dev_menu_entry.tscn")
@onready var close_button = $CloseButton as Button
@onready var rect = $ColorRect as ColorRect

# var instance = dev_menu_entry.instantiate().with_data(data)
#	add_child(instance)

# Called when the node enters the scene tree for the first time.
# Probably have to figure out how to do scrollable screen at some point
func _ready():
	
	var screen_pos = 0;
	for label in EngineTweakable.val:
		var instance = dev_menu_entry.instantiate().with_data(label, screen_pos, EngineTweakable)
		rect.add_child(instance)
		screen_pos += 35
		
		
	close_button.position.y = screen_pos
	hide() # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func open():
	show()

func close():
	get_tree().paused = false
	hide()


func _on_close_button_pressed():
	print("pressed")
	close()

