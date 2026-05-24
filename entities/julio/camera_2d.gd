extends Camera2D

@export_group("Screen Shake (Trauma)")
@export var trauma_reduction_rate: float = 1.0
@export var max_offset: Vector2 = Vector2(25.0, 25.0)
@export var max_roll: float = 0.1 # (leve inclinação)
@export var noise_speed: float = 50.0

@export_group("Look Ahead")
@export var look_ahead_distance: float = 50.0
@export var look_ahead_speed: float = 3.0

var trauma: float = 0.0
var time: float = 0.0

@onready var noise := FastNoiseLite.new()
@onready var player: CharacterBody2D = get_parent()

func _ready() -> void:
	# Configura o ruído para gerar movimentos orgânicos e imprevisíveis
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	
	# Habilita o smoothing nativo do Godot para o rastreamento principal
	position_smoothing_enabled = true
	position_smoothing_speed = 5.0

func _physics_process(delta: float) -> void:
	# 1. Atualiza o Look Ahead (Antecipação visual)
	_apply_look_ahead(delta)
	
	# 2. Atualiza e aplica o Shake
	if trauma > 0.0:
		time += delta * noise_speed
		trauma = max(trauma - trauma_reduction_rate * delta, 0.0)
		_apply_shake()
	else:
		# Quando não há trauma, garante que o offset e a rotação voltem ao zero
		offset = Vector2.ZERO
		rotation = 0.0

# Chame esta função de outros scripts (ex: do script do Player)
# Passe um valor entre 0.0 e 1.0 dependendo da força do impacto
func add_trauma(amount: float) -> void:
	trauma = min(trauma + amount, 1.0)

func _apply_shake() -> void:
	# O quadrado do trauma (trauma^2) é o segredo aqui: 
	# Faz com que tremores baixos sejam bem sutis, mas impactos altos (próximos de 1.0) sejam violentos
	var shake_amount = trauma * trauma 
	
	# O noise gera valores suaves entre -1 e 1
	offset.x = max_offset.x * shake_amount * noise.get_noise_2d(time, 0.0)
	# Passamos "100.0" no Y para que o eixo Y use um trecho diferente do ruído e não fique idêntico ao X
	offset.y = max_offset.y * shake_amount * noise.get_noise_2d(time, 100.0) 
	rotation = max_roll * shake_amount * noise.get_noise_2d(time, 200.0)

func _apply_look_ahead(delta: float) -> void:
	var target_position = Vector2.ZERO
	
	# Se o player estiver se movendo, desloca a câmera para a frente
	if player and abs(player.velocity.x) > 10:
		var direction_x = sign(player.velocity.x)
		target_position.x = direction_x * look_ahead_distance
		
	# Interpola a posição local da câmera suavemente
	position = position.lerp(target_position, look_ahead_speed * delta)
