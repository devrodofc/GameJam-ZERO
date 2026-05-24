extends Area2D

# ==========================================
# CONFIGURAÇÕES DO TEXTO E BOTÃO
# ==========================================
@export_group("Textos")
@export var prompt_text: String = "[E] Interagir"
@export var interaction_message: String = "Interagindo com um item..."
@export var is_one_shot: bool = false

@export_group("Visual do Prompt [E]")
@export var prompt_color: Color = Color.YELLOW
@export var prompt_size: int = 32
@export var prompt_offset_y: float = 80.0

@export_group("Visual da Mensagem Flutuante")
@export var text_color: Color = Color.WHITE
@export var font_size: int = 32
@export var text_offset_y: float = 100.0
@export var text_offset_x: float = -200.0

var player_ref: Node2D = null
var prompt_label: Label = null
var has_interacted: bool = false

# ==========================================
# INICIALIZAÇÃO
# ==========================================
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Cria a etiqueta "[E] Interagir" automaticamente
	prompt_label = Label.new()
	prompt_label.text = prompt_text
	prompt_label.add_theme_color_override("font_color", prompt_color)
	prompt_label.add_theme_font_size_override("font_size", prompt_size)
	
	prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	prompt_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	
	# Adiciona o prompt como filho deste objeto
	add_child(prompt_label)
	prompt_label.position = Vector2(0, -prompt_offset_y)
	
	# Começa invisível
	prompt_label.hide()

# ==========================================
# DETECÇÃO DO JOGADOR
# ==========================================
func _on_body_entered(body: Node2D) -> void:
	# Se já interagiu e é de uso único, ignora
	if is_one_shot and has_interacted:
		return
		
	if body.is_in_group("player"):
		player_ref = body
		prompt_label.show() # Mostra o botão [E]
		
		# Animação suave para o prompt aparecendo (Bounce)
		prompt_label.scale = Vector2.ZERO
		var tween = create_tween()
		tween.tween_property(prompt_label, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_SPRING)

func _on_body_exited(body: Node2D) -> void:
	if body == player_ref:
		player_ref = null
		prompt_label.hide() # Esconde o botão [E]

# ==========================================
# AÇÃO DE INTERAÇÃO (Apertar "E")
# ==========================================
func _process(_delta: float) -> void:
	# Se o player estiver na área e apertar o botão de interação
	if player_ref and Input.is_action_just_pressed("interact"):
		_trigger_interaction()

func _trigger_interaction() -> void:
	# Esconde o prompt para não ficar poluição visual enquanto lê
	prompt_label.hide()
	
	# ------------------------------------------------------------------
	# TEXTO FLUTUANTE (SEGUE O JOGADOR)
	# ------------------------------------------------------------------
	var popup_label = Label.new()
	popup_label.text = interaction_message
	
	popup_label.add_theme_color_override("font_color", text_color)
	popup_label.add_theme_font_size_override("font_size", font_size)
	
	popup_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	popup_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	popup_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	
	# A mensagem vira filha do Player para seguir ele
	player_ref.add_child(popup_label)
	
	popup_label.position = Vector2(text_offset_x, -text_offset_y)
	
	# Animação da mensagem subindo
	var text_tween = popup_label.create_tween()
	text_tween.tween_property(popup_label, "position:y", popup_label.position.y - 60.0, 2.5).set_ease(Tween.EASE_OUT)
	text_tween.parallel().tween_property(popup_label, "modulate:a", 0.0, 2.5).set_ease(Tween.EASE_IN)
	text_tween.tween_callback(popup_label.queue_free)
	# ------------------------------------------------------------------
	
	if is_one_shot:
		has_interacted = true
		player_ref = null # Desconecta o player para não interagir de novo
	else:
		# Se puder ler de novo, faz o botão [E] reaparecer depois de um tempinho
		await get_tree().create_timer(1.0).timeout
		if player_ref: # Checa se o player ainda tá na área
			prompt_label.show()
