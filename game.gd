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
		
		
#func print_something():
	#print("FOUND ME")
