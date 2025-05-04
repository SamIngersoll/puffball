@tool
extends Control
# dev menu entry can be used to instantiate and change any of the 
# singletons, provided they have a dict stored in the '.val' field
var dev_menu_entry = preload("res://gui/dev_menu_entry.tscn")
@onready var close_button = $CloseButton as Button
@onready var col_rect = $ColorRect as ColorRect
@onready var rect = $ScrollContainer/VBoxContainer as VBoxContainer
# var instance = dev_menu_entry.instantiate().with_data(data)
#	add_child(instance)

#
func get_all_exported_variables():
	print("children of tree")
	var exported_vars = []
	var children = get_tree().get_nodes_in_group("levels")[0].get_children()
	for child in children:
		var exported_vars_chunk = get_exported_variables(child)
		if exported_vars_chunk != []:
			for variable in exported_vars_chunk:
				#if typeof(variable) != TYPE_STRING:
				EngineTweakable.val[child.name+" / "+variable.name] = child.get(variable.name)
				print(variable.name)
				print(child.get(variable.name))
				#pass
			#exported_vars.append(exported_vars_chunk)
	#print("exported vars")
	#print(exported_vars)

# Called when the node enters the scene tree for the first time.
# Probably have to figure out how to do scrollable screen at some point
func get_exported_variables(node: Node) -> Array:
	var exported_vars = []
	var script = node.get_script()
	if script:
		for prop in script.get_script_property_list():
			if prop.has("usage") and (prop.usage & PROPERTY_USAGE_STORAGE) and (prop.usage & PROPERTY_USAGE_EDITOR):
				#if (prop.type == 3):
				exported_vars.append(prop)
				#print(prop)
	return exported_vars

func _ready():
	get_all_exported_variables()
	print("EngineTweakable.val")
	print(EngineTweakable.val)
	var screen_pos = 0;
	
	for label in EngineTweakable.val:
		var instance = dev_menu_entry.instantiate().with_data(label, screen_pos, EngineTweakable)
		rect.add_child(instance)
		#screen_pos += 35
		#screen_pos += 100
		
	close_button.position.y = screen_pos
	var exports = get_exported_variables(get_tree().get_nodes_in_group("player")[0])
	#print(exports)
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
