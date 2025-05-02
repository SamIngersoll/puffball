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
func get_exported_variables(node: Node) -> Array:
	var exported_vars = []
	var script = node.get_script()
	if script:
		for prop in script.get_script_property_list():
			if prop.has("usage") and (prop.usage & PROPERTY_USAGE_STORAGE) and (prop.usage & PROPERTY_USAGE_EDITOR):
				exported_vars.append(prop.name)
	return exported_vars

func _ready():
	
	var screen_pos = 0;
	for label in EngineTweakable.val:
		var instance = dev_menu_entry.instantiate().with_data(label, screen_pos, EngineTweakable)
		rect.add_child(instance)
		screen_pos += 35
		
		
	close_button.position.y = screen_pos
	var exports = get_exported_variables(get_tree().get_nodes_in_group("player")[0])
	print(exports)
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
