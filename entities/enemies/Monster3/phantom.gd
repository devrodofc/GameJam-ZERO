extends EnemyBase

enum State { ORBIT, PREPARE, CHARGE, COOLDOWN }
var current_state: State = State.ORBIT

@onready var AnimatedSprite : AnimatedSprite2D = $AnimatedSprite2D

@export_group("Órbita")
@export var orbit_radius: float = 120.0
@export var orbit_speed: float = 2.0
@export var orbit_time: float = 3.0

@export_group("Ataque")
@export var charge_speed: float = 600.0
@export_group("Ataque")
@export var charge_overshoot: float = 80.0
@export_group("Ataque")
@export var prepare_time: float = 0.6
@export_group("Ataque")
@export var cooldown_time: float = 0.8

var state_timer: float = 0.0
var current_angle: float = 0.0
var charge_target: Vector2 = Vector2.ZERO
var player: Node2D = null

func _ready() -> void:
	super()
	player = get_tree().get_first_node_in_group("player")
	change_state(State.ORBIT)

func _physics_process(delta: float) -> void:
	if not player or is_dead:
		return 

	var dir_to_player = global_position.direction_to(player.global_position)

	match current_state:
		State.ORBIT:
			current_angle += orbit_speed * delta
			
			var ideal_position = player.global_position + Vector2(cos(current_angle), sin(current_angle)) * orbit_radius
			velocity = (ideal_position - global_position) * 4.0
			
			state_timer -= delta
			if state_timer <= 0.0:
				change_state(State.PREPARE)

		State.PREPARE:
			velocity = velocity.lerp(Vector2.ZERO, 6.0 * delta)
			
			state_timer -= delta
			if state_timer <= 0.0:
				charge_target = player.global_position + (dir_to_player * charge_overshoot)
				change_state(State.CHARGE)

		State.CHARGE:
			var dir_to_target = global_position.direction_to(charge_target)
			velocity = dir_to_target * charge_speed
			
			state_timer -= delta
			
			if global_position.distance_to(charge_target) < 15.0 or state_timer <= 0.0:
				change_state(State.COOLDOWN)

		State.COOLDOWN:
			velocity = velocity.lerp(Vector2.ZERO, 4.0 * delta)
			
			state_timer -= delta
			if state_timer <= 0.0:
				change_state(State.ORBIT)

	move_and_slide()
	_update_animations()

func change_state(new_state: State) -> void:
	current_state = new_state
	match new_state:
		State.ORBIT:
			state_timer = orbit_time
			if player:
				current_angle = (global_position - player.global_position).angle()
				
		State.PREPARE:
			state_timer = prepare_time
			
		State.CHARGE:
			state_timer = 1.0 
			
		State.COOLDOWN:
			state_timer = cooldown_time

func _update_animations() -> void:
	if player:
		if player.global_position.x < global_position.x:
			AnimatedSprite.flip_h = true
		else:
			AnimatedSprite.flip_h = false

	if current_state == State.CHARGE or current_state == State.PREPARE:
		AnimatedSprite.play("attack")
	else:
		AnimatedSprite.play("circling")
