extends ProgressBar

@onready var _damage_bar := $DamageBar as ProgressBar
@onready var _catch_up_timer := $Timer as Timer

var health = 0 

func _set_health(_new_health, init : bool):
	print("new health", _new_health)
	if init:
		init_health(_new_health)
	else:
		var previous_health = health
		health = _new_health
		value = health
	
		if health < previous_health:
			_catch_up_timer.start()
		else:
			_damage_bar.value = health
	
func init_health(_health):
	print("health", _health)
	health = _health
	max_value = health
	value = health
	$DamageBar.max_value = health
	$DamageBar.value = health
	

func _on_timer_timeout() -> void:
	_damage_bar.value = health
