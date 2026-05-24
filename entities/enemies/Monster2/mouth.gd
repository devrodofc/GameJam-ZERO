extends EnemyBase

# ==========================================
# ESTADOS DA MOUTH
# ==========================================
enum State { ZONING, PREPARE_SHOOT, COOLDOWN }
var current_state: State = State.ZONING

# ==========================================
# CONFIGURAÇÕES DE FÍSICA E PULO
# ==========================================
@export_group("Física")
@export var move_speed: float = 160.0
@export var gravity: float = 980.0
@export var jump_force: float = -450.0 
@export var jump_threshold: float = 40.0 

# ==========================================
# CONFIGURAÇÕES DE COMBATE
# ==========================================
@export_group("Táticas de Combate")
@export var min_distance: float = 150.0  # Se chegar mais perto que 150, ela dá ré
@export var max_distance: float = 250.0  # Se afastar mais que 250, ela vai atrás
@export var time_to_shoot: float = 2.0   # Tempo entre um tiro e outro
@export var prepare_time: float = 0.4    # Tempo parada "carregando" o tiro
@export var cooldown_time: float = 0.8   # Tempo de recuperação após atirar

@export_group("Projétil")
@export var projectile_scene: PackedScene # ARRASTE A CENA DO TIRO AQUI NO INSPECTOR!
@export var projectile_speed: float = 400.0

var state_timer: float = 0.0
var shoot_timer: float = 0.0
var player: Node2D = null

# ==========================================
# INICIALIZAÇÃO
# ==========================================
func _ready() -> void:
	# MUDANÇA AQUI: Chama o _ready() do EnemyBase para carregar a Vida e a Cor!
	super()
	
	player = get_tree().get_first_node_in_group("player")
	
	# Tempo inicial para o primeiro tiro (com leve aleatoriedade)
	shoot_timer = time_to_shoot + randf_range(-0.5, 0.5)

# ==========================================
# LOOP DE FÍSICA E IA
# ==========================================
func _physics_process(delta: float) -> void:
	if is_dead or not player: 
		return 

	# 1. Aplica a Gravidade e Pulo (Inteligência vertical mantida)
	if not is_on_floor():
		velocity.y += gravity * delta
	elif current_state == State.ZONING:
		# Pula caso o jogador esteja em uma plataforma acima dela
		if player.global_position.y < global_position.y - jump_threshold:
			velocity.y = jump_force

	# 2. Cálculos de Distância e Direção
	var dist_to_player_x = abs(player.global_position.x - global_position.x)
	var dir_to_player = sign(player.global_position.x - global_position.x)
	
	if dir_to_player == 0: 
		dir_to_player = 1 

	# 3. Máquina de Estados
	match current_state:
		
		# ZONING: Mantendo a distância ideal
		State.ZONING:
			if dist_to_player_x > max_distance:
				velocity.x = dir_to_player * move_speed
			elif dist_to_player_x < min_distance:
				velocity.x = -dir_to_player * move_speed
			else:
				velocity.x = move_toward(velocity.x, 0, 800 * delta)
				
			shoot_timer -= delta
			
			# Tenta atirar apenas se estiver no chão
			if shoot_timer <= 0.0 and is_on_floor():
				change_state(State.PREPARE_SHOOT)

		# PREPARANDO: Freia e avisa que vai atirar
		State.PREPARE_SHOOT:
			velocity.x = move_toward(velocity.x, 0, 1500 * delta)
			
			state_timer -= delta
			if state_timer <= 0.0:
				shoot_projectile()
				change_state(State.COOLDOWN)

		# COOLDOWN: Tempo parada após atirar
		State.COOLDOWN:
			velocity.x = move_toward(velocity.x, 0, 1200 * delta)
			
			state_timer -= delta
			if state_timer <= 0.0:
				change_state(State.ZONING)

	# 4. Aplica o movimento
	move_and_slide()

# ==========================================
# TRANSIÇÃO DE ESTADOS
# ==========================================
func change_state(new_state: State) -> void:
	current_state = new_state
	
	match new_state:
		State.ZONING:
			shoot_timer = time_to_shoot + randf_range(-0.5, 0.5)
		State.PREPARE_SHOOT:
			state_timer = prepare_time
		State.COOLDOWN:
			state_timer = cooldown_time

# ==========================================
# SISTEMA DE TIRO
# ==========================================
func shoot_projectile() -> void:
	# Prevenção de erro caso você esqueça de colocar a cena do tiro no Inspector
	if not projectile_scene or not player:
		push_warning("Mouth tentou atirar, mas não tem uma projectile_scene assinalada!")
		return
		
	# Instancia o tiro
	var proj = projectile_scene.instantiate()
	
	# Adiciona o tiro ao cenário principal (NÃO como filho da Mouth, senão o tiro se move junto com ela)
	get_tree().current_scene.add_child(proj)
	
	# Nasce na mesma posição da Mouth
	proj.global_position = global_position
	
	# Calcula a direção exata para o player (mira teleguiada no momento do disparo)
	var shoot_dir = global_position.direction_to(player.global_position)
	
	# Envia as informações pro script do projétil 
	if "velocity" in proj:
		proj.velocity = shoot_dir * projectile_speed
