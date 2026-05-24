extends CharacterBody2D

# ==========================================
# CONFIGURAÇÕES DE MOVIMENTO
# ==========================================
@export_group("Física")
@export var speed: float = 100.0
@export var acceleration: float = 150.0 
@export var friction: float = 200.0 
@export var gravity: float = 980.0

# ==========================================
# CONFIGURAÇÕES DO TEXTO
# ==========================================
@export_group("Texto de Exaustão")
@export var tired_text_color: Color = Color(0.6, 0.6, 0.6) 
@export var tired_font_size: int = 14

func _physics_process(delta: float) -> void:
	# 1. APLICA A GRAVIDADE
	if not is_on_floor():
		velocity.y += gravity * delta

	# 2. DETECTA O INPUT (Esquerda e Direita)
	var direction = Input.get_axis("move_left", "move_right")

	# 3. APLICA A VELOCIDADE HORIZONTAL (Com inércia e peso)
	if direction != 0:
		# Personagem faz esforço para começar a andar
		velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
	else:
		# Personagem solta o peso do corpo e vai parando aos poucos
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		
	# 4. TENTATIVA DE PULO
	if Input.is_action_just_pressed("jump"):
		_show_tired_message()

	# 5. EXECUTA O MOVIMENTO E COLISÕES
	move_and_slide()

# ==========================================
# MENSAGEM FLUTUANTE
# ==========================================
func _show_tired_message() -> void:
	var popup_label = Label.new()
	popup_label.text = "Sem energia para pulos..."
	
	# Estiliza o texto (Cor e Tamanho)
	popup_label.add_theme_color_override("font_color", tired_text_color)
	popup_label.add_theme_font_size_override("font_size", tired_font_size)
	
	# Centraliza
	popup_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	popup_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	popup_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	
	# Adiciona a mensagem como filha do jogador (para que o texto ande junto com ele)
	add_child(popup_label)
	
	# Posição inicial (acima da cabeça)
	popup_label.position = Vector2(0, -80.0)
	
	# Animação arrastada
	var text_tween = popup_label.create_tween()
	text_tween.tween_property(popup_label, "position:y", popup_label.position.y - 20.0, 2.5).set_ease(Tween.EASE_OUT)
	text_tween.parallel().tween_property(popup_label, "modulate:a", 0.0, 2.5).set_ease(Tween.EASE_IN)
	text_tween.tween_callback(popup_label.queue_free)
