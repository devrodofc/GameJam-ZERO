extends EnemyBase 

# ==========================================
# ESTADOS DO SALTADOR
# ==========================================
enum State { IDLE, JUMPING }
var current_state: State = State.IDLE

# ==========================================
# CONFIGURAÇÕES DE PULO E GRAVIDADE
# ==========================================
@export_group("Física do Pulo")
@export var jump_force: float = -450.0
@export var chase_speed: float = 200.0
@export var gravity: float = 980.0
@export var ground_friction: float = 1500.0 # O quão rápido ele freia ao tocar no chão

@export_group("Tempos")
@export var jump_cooldown: float = 0.8 # Tempo que ele fica parado antes de pular de novo

var state_timer: float = 0.0
var player: Node2D = null

# ==========================================
# INICIALIZAÇÃO
# ==========================================
func _ready() -> void:
	# Chama a função _ready() do EnemyBase para carregar a Vida e a Cor!
	super() 
	
	player = get_tree().get_first_node_in_group("player")
	state_timer = jump_cooldown

# ==========================================
# LOOP DE FÍSICA E IA
# ==========================================
func _physics_process(delta: float) -> void:
	# A variável is_dead vem de herança do EnemyBase
	if is_dead or not player: 
		return 

	# 1. Aplica a Gravidade
	if not is_on_floor():
		velocity.y += gravity * delta
		current_state = State.JUMPING
	else:
		# Acabou de tocar no chão (Transição de JUMPING para IDLE)
		if current_state == State.JUMPING:
			current_state = State.IDLE
			state_timer = jump_cooldown # Inicia o relógio para o próximo pulo

	# 2. Máquina de Estados
	match current_state:
		State.IDLE:
			# Freia o inimigo para ele não escorregar no chão que nem sabão
			velocity.x = move_toward(velocity.x, 0, ground_friction * delta)
			
			state_timer -= delta
			
			# O tempo de espera acabou? Hora de atacar!
			if state_timer <= 0.0:
				jump_towards_player()
				
		State.JUMPING:
			# Enquanto está no ar, apenas sofre ação da gravidade e do impulso inicial
			pass
			
	# 3. Executa o movimento e colisões com o cenário
	move_and_slide()

# ==========================================
# LÓGICA DE PERSEGUIÇÃO
# ==========================================
func jump_towards_player() -> void:
	# A função sign() retorna 1 (se o player estiver na direita) ou -1 (na esquerda)
	var direction = sign(player.global_position.x - global_position.x)
	
	# Caso raro: se os dois estiverem no exato mesmo pixel, força ele a pular para um lado
	if direction == 0:
		direction = 1 
		
	# Aplica o impulso vertical (pulo) e horizontal (velocidade na direção do player)
	velocity.y = jump_force
	velocity.x = direction * chase_speed
	
	# Atualiza o estado
	current_state = State.JUMPING
