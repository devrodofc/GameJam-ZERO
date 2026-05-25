extends EnemyBase

enum State { ZONING, PREPARE_SHOOT, COOLDOWN }
var current_state: State = State.ZONING

@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D

@export_group("Física")
@export var move_speed: float = 160.0
@export var gravity: float = 980.0
@export var jump_force: float = -450.0 
@export var jump_threshold: float = 40.0 

@export_group("Táticas de Combate")
@export var min_distance: float = 150.0 
@export var max_distance: float = 250.0 
@export var time_to_shoot: float = 2.0   
@export var prepare_time: float = 0.4    
@export var cooldown_time: float = 0.8   

@export_group("Projétil")
@export var projectile_scene: PackedScene 
@export var projectile_speed: float = 400.0

var state_timer: float = 0.0
var shoot_timer: float = 0.0
var player: Node2D = null

func _ready() -> void:
	super()
	player = get_tree().get_first_node_in_group("player")
	shoot_timer = time_to_shoot + randf_range(-0.5, 0.5)

func _physics_process(delta: float) -> void:
	if is_dead or not player: 
		return 

	if not is_on_floor():
		velocity.y += gravity * delta
	elif current_state == State.ZONING:
		if player.global_position.y < global_position.y - jump_threshold:
			velocity.y = jump_force

	var dist_to_player_x = abs(player.global_position.x - global_position.x)
	var dir_to_player = sign(player.global_position.x - global_position.x)
	
	if dir_to_player == 0: 
		dir_to_player = 1 

	match current_state:
		State.ZONING:
			if dist_to_player_x > max_distance:
				velocity.x = dir_to_player * move_speed
			elif dist_to_player_x < min_distance:
				velocity.x = -dir_to_player * move_speed
			else:
				velocity.x = move_toward(velocity.x, 0, 800 * delta)
				
			shoot_timer -= delta
			
			if shoot_timer <= 0.0 and is_on_floor():
				change_state(State.PREPARE_SHOOT)

		State.PREPARE_SHOOT:
			velocity.x = move_toward(velocity.x, 0, 1500 * delta)
			
			state_timer -= delta
			if state_timer <= 0.0:
				shoot_projectile()
				change_state(State.COOLDOWN)

		State.COOLDOWN:
			velocity.x = move_toward(velocity.x, 0, 1200 * delta)
			
			state_timer -= delta
			if state_timer <= 0.0:
				change_state(State.ZONING)

	move_and_slide()
	_update_animations()

func change_state(new_state: State) -> void:
	current_state = new_state
	
	match new_state:
		State.ZONING:
			shoot_timer = time_to_shoot + randf_range(-0.5, 0.5)
		State.PREPARE_SHOOT:
			state_timer = prepare_time
		State.COOLDOWN:
			state_timer = cooldown_time

func shoot_projectile() -> void:
	if not projectile_scene or not player:
		push_warning("Mouth tentou atirar, mas não tem uma projectile_scene!!")
		return
		
	var proj = projectile_scene.instantiate()
	get_tree().current_scene.add_child(proj)
	proj.global_position = global_position
	
	var shoot_dir = global_position.direction_to(player.global_position)
	
	if "velocity" in proj:
		proj.velocity = shoot_dir * projectile_speed

func _update_animations() -> void:
	if player:
		if player.global_position.x < global_position.x:
			animated_sprite.flip_h = true
		else:
			animated_sprite.flip_h = false

	if current_state == State.PREPARE_SHOOT:
		animated_sprite.play("kiss")
	else:
		if abs(velocity.x) > 10.0:
			animated_sprite.play("walk")
		else:
			animated_sprite.play("walk")
