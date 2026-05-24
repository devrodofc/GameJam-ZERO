extends CharacterBody2D

# ==========================================
# REFERÊNCIAS
# ==========================================
@onready var camera = $Camera2D

# ==========================================
# CONFIGURAÇÕES DE VIDA E COMBATE
# ==========================================
@export_category("Life & Combat")
@export var max_health := 6
@export var invincibility_duration: float = 1.5 # Tempo de I-Frames (em segundos)

@onready var Hearths_container = $Heaths
@export var hearth_scene : PackedScene

var current_health: int
var is_invincible: bool = false # Controla se o jogador pode tomar dano

# ==========================================
# CONFIGURAÇÕES DE MOVIMENTO
# ==========================================
@export_category("Movement")
@export var speed: float = 300.0
@export var acceleration: float = 1500.0
@export var friction: float = 1200.0
var was_on_floor: bool = true
var last_velocity_y: float = 0.0

# ==========================================
# CONFIGURAÇÕES DE PULO E GRAVIDADE
# ==========================================
@export var jump_force: float = -450.0
@export var gravity: float = 980.0
@export var fall_gravity_multiplier: float = 1.5
@export var fast_fall_multiplier: float = 3.5

# ==========================================
# PULO DUPLO E SUSTENTAÇÃO NO ÁPICE (HANG)
# ==========================================
@export var double_jump_force: float = 600.0 
@export var apex_hang_threshold: float = 100.0
@export var apex_hang_gravity_mult: float = 0.15 

var can_double_jump: bool = false
var is_jumping: bool = false

# ==========================================
# (GAME FEEL)
# ==========================================
@export var coyote_time: float = 0.1
@export var jump_buffer_time: float = 0.1

var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0

# ==========================================
# INICIALIZAÇÃO
# ==========================================
func _ready() -> void:
	current_health = max_health
	_initialize_hearts()

func _physics_process(delta: float) -> void:
	var current_is_floor = is_on_floor()

	# (HEAVY LANDING)
	if current_is_floor and not was_on_floor:
		if last_velocity_y > 600.0:
			if camera and camera.has_method("add_trauma"):
				camera.add_trauma(0.2)

	if current_is_floor:
		coyote_timer = coyote_time
		can_double_jump = true
		is_jumping = false
	else:
		coyote_timer -= delta
		
	jump_buffer_timer -= delta
	
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time
		
	# ==========================================
	# FÍSICA NORMAL E GRAVIDADE DINÂMICA
	# ==========================================
	if not current_is_floor:
		var applied_gravity = gravity
		
		if Input.is_action_pressed("look_down"):
			applied_gravity = gravity * fast_fall_multiplier
		elif velocity.y > 0: 
			applied_gravity = gravity * fall_gravity_multiplier

		if abs(velocity.y) < apex_hang_threshold and Input.is_action_pressed("jump") and not Input.is_action_pressed("look_down"):
			applied_gravity = gravity * apex_hang_gravity_mult
			
		velocity.y += applied_gravity * delta

	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= 0.5 

	if jump_buffer_timer > 0:
		if coyote_timer > 0:
			velocity.y = jump_force
			jump_buffer_timer = 0.0
			coyote_timer = 0.0
			is_jumping = true
			
		elif can_double_jump:
			var aim_direction = Input.get_vector("move_left", "move_right", "look_up", "look_down")
			if aim_direction == Vector2.ZERO:
				aim_direction = Vector2.UP
				
			velocity = aim_direction.normalized() * double_jump_force
			
			if camera and camera.has_method("add_trauma"):
				camera.add_trauma(0.3) 
				
			jump_buffer_timer = 0.0
			can_double_jump = false
			is_jumping = true

	var direction = Input.get_axis("move_left", "move_right")

	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)

	last_velocity_y = velocity.y

	move_and_slide()

	was_on_floor = current_is_floor


# ==========================================
# SISTEMA DE VIDA E DANO (COM I-FRAMES)
# ==========================================
func _initialize_hearts() -> void:
	if Hearths_container:
		for child in Hearths_container.get_children():
			child.queue_free()
			
		if hearth_scene:
			for i in range(current_health):
				var heart = hearth_scene.instantiate()
				Hearths_container.add_child(heart)

func Hurt() -> void:
	take_damage(1)

func take_damage(amount: int = 1) -> void:
	# Ignora o dano se o jogador já estiver morto ou estiver no período de I-Frames
	if current_health <= 0 or is_invincible:
		return 
		
	current_health = max(current_health - amount, 0)
	_update_hearts()
	
	if camera and camera.has_method("add_trauma"):
		camera.add_trauma(0.5)
	
	if current_health == 0:
		die()
	else:
		# Se sobreviveu ao golpe, ativa a invencibilidade temporária
		trigger_iframes()

func trigger_iframes() -> void:
	is_invincible = true
	
	# Animação do personagem piscando
	var tween = create_tween()
	# Calcula quantas vezes ele deve piscar baseado na duração (pisca a cada 0.2 segundos)
	var blink_count = int(invincibility_duration / 0.2)
	
	tween.set_loops(blink_count)
	tween.tween_property(self, "modulate:a", 0.3, 0.1) # Fica transparente
	tween.tween_property(self, "modulate:a", 1.0, 0.1) # Volta ao normal
	
	# Cria um timer independente para acabar com a invencibilidade
	await get_tree().create_timer(invincibility_duration).timeout
	
	# Restaura tudo ao normal ao fim do tempo
	is_invincible = false
	modulate.a = 1.0 # Garante que a transparência fique em 100% no final

func _update_hearts() -> void:
	if Hearths_container:
		var hearts = Hearths_container.get_children()
		for i in range(hearts.size()):
			if i >= current_health:
				hearts[i].queue_free()

func die() -> void:
	print("Player morreu!")
	# get_tree().reload_current_scene()
