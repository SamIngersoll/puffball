class_name NPC extends CharacterBody2D

@export_group("My Properties")

enum State {
	IDLE,
	DEAD,
}

var _state := State.IDLE

@onready var sprite := $Sprite2D as Sprite2D
@onready var animation_player := $AnimationPlayer as AnimationPlayer
@onready var alert := $Exclamation as Sprite2D

func _physics_process(delta: float) -> void:
	# could be used to look at player.
	#if position.x > player.position.x:
		#sprite.scale.x = 0.8
	#elif position.x < player.position.x:
		#sprite.scale.x = -0.8

	var animation := get_new_animation()
	if animation != animation_player.current_animation:
		animation_player.play(animation)


func destroy() -> void:
	_state = State.DEAD
	velocity = Vector2.ZERO


func get_new_animation() -> StringName:
	var animation_new: StringName
	if _state == State.IDLE:
		animation_new = &"idle"
	else:
		animation_new = &"destroy"
	return animation_new


func _on_area_2d_body_entered(body):
	alert.show()
	print("player entered area")


func _on_area_2d_body_exited(body):
	print("player exited area")
	alert.hide()
