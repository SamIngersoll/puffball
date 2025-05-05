class_name Game extends Node

@onready var _pause_menu := $InterfaceLayer/PauseMenu as PauseMenu
@onready var _dev_menu := $InterfaceLayer/DevMenu as Control

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"toggle_fullscreen"):
		var mode := DisplayServer.window_get_mode()
		if mode == DisplayServer.WINDOW_MODE_FULLSCREEN or \
				mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		get_tree().root.set_input_as_handled()

	elif event.is_action_pressed(&"toggle_pause"):
		var tree := get_tree()
		tree.paused = not tree.paused
		if tree.paused:
			_pause_menu.open()
		else:
			_pause_menu.close()
		get_tree().root.set_input_as_handled()
		
	elif event.is_action_pressed(&"toggle_dev_menu"):
		var tree := get_tree()
		tree.paused = not tree.paused
		if tree.paused:
			_dev_menu.open()
		else:
			_dev_menu.close()
		get_tree().root.set_input_as_handled()

# initialize dialogic
func _input(event: InputEvent):
	# check if a dialog is already running
	if Dialogic.current_timeline != null:
		return

	if event is InputEventKey and event.keycode == KEY_ENTER and event.pressed:
		print(Global.currently_interactable_NPC)
		Dialogic.start(Global.currently_interactable_NPC)
		get_viewport().set_input_as_handled()
		
# deletes the current level and loads in a specified new level
# argument: string with level name
func change_level(new_level_name):
	var active_level = get_tree().get_first_node_in_group("levels")
	var game = active_level.get_parent()
	#get_tree().change_scene_to_file("res://levels/"+new_level_name+".tscn")
	game.add_child(load("res://levels/"+new_level_name+".tscn").instantiate())
	active_level.queue_free()
	#active_level = get_tree().get_first_node_in_group("levels")
	#active_level.reparent(game)
	
func reset_level():
	get_tree().reload_current_scene()
	#var active_level = get_tree().get_first_node_in_group("levels")
	#var game_obj = active_level.get_parent()
	#var new_level_name = active_level.get_name()
	#
	#active_level.set_name("removed")
	#print(new_level_name)
	##get_tree().change_scene_to_file("res://levels/"+new_level_name+".tscn")
	#game_obj.add_child(load("res://levels/"+new_level_name+".tscn").instantiate())
	#active_level.queue_free()
	
	
	
