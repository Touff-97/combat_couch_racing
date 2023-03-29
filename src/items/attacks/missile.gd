extends Spatial

const LAUNCH_SPEED := 50.0
const EXPLOSION := preload("res://src/particles/explosion.tscn")

export(Texture) var icon
export(int) var ammo
export(float) var cooldown
export(bool) var can_spray

export var lifetime := 20.0
export var damage := 10.0

var max_speed := 20.0
var drag_factor := 0.15 setget set_drag_factor

var launcher : Spatial
var target : Spatial

var current_velocity := Vector3.ZERO

onready var mesh: MeshInstance = $Mesh
onready var hit_box: Area = $HitBox
onready var enemy_detector: Area = $EnemyDetector
onready var self_destruct_timer: Timer = $SelfDestructTimer
onready var propulsion: CPUParticles = $Propulsion
onready var explosion_timer: Timer = $ExplosionTimer


func set_drag_factor(new_factor: float) -> void:
	drag_factor = new_factor


func _ready() -> void:
	set_as_toplevel(true)
	
	self_destruct_timer.start(lifetime)
	
	current_velocity = max_speed * -get_global_transform().basis.z
	
	propulsion.emitting = true


func _physics_process(delta: float) -> void:
	var direction := -get_global_transform().basis.z.normalized()
	
	if target:
		direction = global_translation.direction_to(target.global_translation)
	
	var desired_velocity = direction * max_speed
	var change = (desired_velocity - current_velocity) * drag_factor
	
	current_velocity += change
	
	translation += current_velocity * delta
	look_at(global_translation + current_velocity, Vector3.UP)


func _on_HitBox_body_entered(body: RigidBody) -> void:
	if body == launcher:
		return
	
	if not target:
		return
	
	body.get_parent().take_damage(damage)
	explode()


func _on_EnemyDetector_body_entered(body: RigidBody) -> void:
	if target:
		return
	
	if not body:
		return
	
	if body == launcher:
		return
	
	target = body


func _on_SelfDestructTimer_timeout() -> void:
	explode()


func explode() -> void:
	$HitBox/CollisionShape.disabled = true
	
	var new_explosion := EXPLOSION.instance()
	add_child(new_explosion, true)
	new_explosion.translation = mesh.translation
	
	propulsion.emitting = false
	mesh.visible = false
	
	new_explosion.emitting = true
	
	explosion_timer.start()


func _on_ExplosionTimer_timeout() -> void:
	queue_free()


func _on_Timer_timeout() -> void:
	$HitBox/CollisionShape.disabled = false
