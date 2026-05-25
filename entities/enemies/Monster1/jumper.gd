extends EnemyBase 

enum State { WALKING, JUMPING }
var current_state: State = State.WALKING
@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D

@export_group("Física do Pulo")
@export var jump_force: float = -450.0
@export var chase_speed: float = 200.0
@export var gravity: float = 980.0

@export_group("Tempos")
@export var jump_cooldown: float = 0.8 

var state_timer: float = 0.0
var player: Node2D = null

func _ready() -> void:
	super() 
	player = get_tree().get_first_node_in_group("player")
	state_timer = jump_cooldown

func _physics_process(delta: float) -> void:
	if is_dead or not player: 
		return 

	if not is_on_floor():
		velocity.y += gravity * delta
		current_state = State.JUMPING
	else:
		if current_state == State.JUMPING:
			current_state = State.WALKING
			state_timer = jump_cooldown 

	match current_state:
		State.WALKING:
			var direction = sign(player.global_position.x - global_position.x)
			if direction == 0:
				direction = 1
			
			velocity.x = direction * (chase_speed * 0.5)
			
			state_timer -= delta
			if state_timer <= 0.0:
				jump_towards_player()
				
		State.JUMPING:
			pass
			
	move_and_slide()
	_update_animations()

func jump_towards_player() -> void:
	var direction = sign(player.global_position.x - global_position.x)
	if direction == 0:
		direction = 1 
		
	velocity.y = jump_force
	velocity.x = direction * chase_speed
	
	current_state = State.JUMPING

func _update_animations() -> void:
	if player:
		if player.global_position.x < global_position.x:
			animated_sprite.flip_h = true
		else:
			animated_sprite.flip_h = false

	if is_on_floor():
		animated_sprite.play("walk")
	else:
		if velocity.y < 0:
			animated_sprite.play("jump")
		else:
			animated_sprite.play("midAir")
