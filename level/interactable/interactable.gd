@tool
extends Node2D

# touchpoint visual appearance
enum Touchpoint_Visual_Appearance {
	NONE,
	BUTTON,
	LEVER,
}

# endpoint visual appearance
enum Endpoint_Visual_Appearance {
	DOOR,
	FAKE_WALL,
	ELEVATOR,
	TRAP_DOOR
}

@onready var animation_player := $AnimationPlayer as AnimationPlayer
@onready var interaction_result_shape := $interaction_result_body/CollisionShape2D as CollisionShape2D
@onready var timer := $timer as Timer

# whether or not the interactable has been activated by the player
@export var active : bool = false

@export_group("Visual properties")

@export var endpoint_visual_appearance : Endpoint_Visual_Appearance = Endpoint_Visual_Appearance.DOOR :
	set(value):
		endpoint_visual_appearance = value
@export var touchpoint_visual_appearance : Touchpoint_Visual_Appearance = Touchpoint_Visual_Appearance.NONE :
	set(value):
		touchpoint_visual_appearance = value
		
@export_group("Trigger options")

# triggering the action
@export var trigger_on_interact : bool = false :
	set(value):
		trigger_on_interact = value
@export var trigger_on_attack : bool = false :
	set(value):
		trigger_on_attack = value
@export var trigger_on_enter : bool = true :
	set(value):
		trigger_on_enter = value
@export var trigger_on_exit : bool = false :
	set(value):
		trigger_on_exit = value
@export var trigger_on_timer : bool = false :
	set(value):
		trigger_on_timer = value
@export var trigger_always : bool = false :
	set(value):
		trigger_always = value
@export var trigger_timer_time : float = 1

@export_group("Reset options")

# resetting the action
@export var reset_on_interact : bool = false :
	set(value):
		reset_on_interact = value
@export var reset_on_attack : bool = false :
	set(value):
		reset_on_attack = value
@export var reset_on_enter : bool = false :
	set(value):
		reset_on_enter = value
@export var reset_on_exit : bool = true :
	set(value):
		reset_on_exit = value
@export var reset_on_timer : bool = false :
	set(value):
		reset_on_timer = value
@export var reset_timer_time : float = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	#animation_player.seek(0)
	if trigger_always:
		change_state_to(!active)
	if trigger_on_timer:
		timer.start(trigger_timer_time)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.is_editor_hint():
	# Code to execute when in editor.
		pass

	if not Engine.is_editor_hint():
	# Code to execute when in game.
		pass
		

func change_state_to(state):
	var trigger_anim = animation_player.get_animation("activate")
	print("changing state")
	if state == true:
		active = true
		#animation_player.speed_scale = 1.0
		animation_player.play("activate")
		interaction_result_shape.debug_color = Color(.6, .6, .1, .4)
	else:
		print("deactivating")
		active = false
		#animation_player.speed_scale = -1.0 
		animation_player.play_backwards("activate")
		interaction_result_shape.debug_color = Color(.6, .1, .1, .4)

# signals
func _on_interaction_area_area_entered(area):
	#print("shape entered")
	if trigger_on_enter and !active:
		change_state_to(true)
	elif reset_on_enter and active:
		change_state_to(false)

func _on_interaction_area_area_exited(area):
	#print("shape exited")
	if trigger_on_exit:
		change_state_to(true)
	elif reset_on_exit:
		change_state_to(false)

func _on_animation_player_animation_finished(anim_name):
	if trigger_always:
		change_state_to(!active)	

func _on_timer_timeout():
	if trigger_on_timer and !active:
		change_state_to(true)
		if reset_on_timer:
			timer.start(reset_timer_time)
	elif reset_on_timer and active:
		change_state_to(false)
		if trigger_on_timer:
			timer.start(trigger_timer_time)
