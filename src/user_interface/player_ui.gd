extends Control

export(float) var health_value setget set_health_value, get_health_value
export(float) var speed_value setget set_speed_value, get_speed_value

onready var health_defense: VBoxContainer = $Margin/BottomUI/HealthDefense
onready var speed_attack: VBoxContainer = $Margin/BottomUI/SpeedAttack

onready var dead_label: Label = $Margin/DeadLabel
onready var dead_timer: Timer = $Margin/DeadLabel/DeadTimer

onready var dead_view_1_animation: AnimationPlayer = $DeadView1/DeadView1Animation
onready var dead_view_2_animation: AnimationPlayer = $DeadView2/DeadView2Animation


func set_health_value(new_health_value: float) -> void:
	health_value = new_health_value
	
	health_defense.get_child(0).value = health_value


func get_health_value() -> float:
	return health_value


func set_speed_value(new_speed_value: float) -> void:
	speed_value = new_speed_value
	
	speed_attack.get_child(0).value = speed_value


func get_speed_value() -> float:
	return speed_value


func _process(delta: float) -> void:
	$Margin/BottomUI/HealthDefense/HealthBar.rect_scale.x = -1


func revive_1() -> void:
	dead_view_1_animation.play("alive")


func revive_2() -> void:
	dead_view_2_animation.play("alive")


func _on_DeadTimer_timeout() -> void:
	if dead_label.text.to_int() > 1:
		dead_label.text = "%s" % str(dead_label.text.to_int() - 1)
	else:
		dead_label.hide()
		dead_label.text = "3"
		dead_timer.stop()
	
