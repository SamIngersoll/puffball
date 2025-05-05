@tool
extends Control
# dev menu entry can be used to instantiate and change any of the 
# singletons, provided they have a dict stored in the '.val' field
var dev_menu_entry = preload("res://gui/dev_menu_entry.tscn")

@onready var close_button = $CloseButton as Button
@onready var col_rect = $ColorRect as ColorRect
@onready var rect = $ScrollContainer/VBoxContainer as VBoxContainer
@onready var level_name : String
# var instance = dev_menu_entry.instantiate().with_data(data)
#	add_child(instance)

func get_all_exported_variables_recursive(node: Node, prefix: String = ""):
	var node_names = node.get_path().get_concatenated_names().rsplit(level_name+"/", false, 1)
	if node_names.size() > 1:
		node_names = node_names.get(1)
	else:
		node_names = node_names.get(0)
	# Get exported variables for this node
	var exported_vars = get_exported_variables(node)
	for variable in exported_vars:
		var full_path = node_names + "/" + variable.name
		EngineTweakable.val[full_path] = node.get(variable.name)
		#print(full_path, " : ", node.get(variable.name))

	# Recurse into children
	for child in node.get_children():
		if child is Node:
			get_all_exported_variables_recursive(child, node_names)
	
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
	level_name = get_tree().get_nodes_in_group("levels")[0].name
	get_all_exported_variables_recursive(get_tree().get_nodes_in_group("levels")[0])

	var screen_pos = 0;
	var dict_size = EngineTweakable.val.size()
	var keys = EngineTweakable.val.keys()
	var label
	for i in range(dict_size):
		label = keys[i]
		var property_value = EngineTweakable.val[label]
		# debug editor can only handle certain types
		
		if (typeof(property_value) == TYPE_STRING 
			or typeof(property_value) == TYPE_FLOAT
			or typeof(property_value) == TYPE_INT 
			or typeof(property_value) == TYPE_BOOL):
			#print("good")
			var instance = dev_menu_entry.instantiate().with_data(label, screen_pos, EngineTweakable)
			rect.add_child(instance)
		else:
			#print("bad")
			EngineTweakable.val.erase(label)
		
	close_button.position.y = screen_pos
	var exports = get_exported_variables(get_tree().get_nodes_in_group("player")[0])
	hide() # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func open():
	get_tree().paused = true
	show()

func close():
	get_tree().paused = false
	hide()


func _on_close_button_pressed():
	print("pressed")
	close()
