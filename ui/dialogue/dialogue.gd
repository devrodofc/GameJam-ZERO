extends CanvasLayer

# ==========================================
# REFERÊNCIAS VISUAIS 
# ==========================================
@onready var caixa_dialogo : NinePatchRect = $CaixaDialogo
@onready var texto_dialogo : RichTextLabel = $CaixaDialogo/Margens/TextoDialogo

# ==========================================
# CONFIGURAÇÕES
# ==========================================
@export var velocidade_texto: float = 40.0
var _tween_texto : Tween = null
var _digitando   : bool  = false

func _ready() -> void:
	visible = false
	texto_dialogo.text = ""
	texto_dialogo.visible_ratio = 0.0

	# Conecta os sinais globais
	if not EventBus.start_dialogue.is_connected(_on_start_dialogue):
		EventBus.start_dialogue.connect(_on_start_dialogue)
	if not EventBus.close_dialogue.is_connected(_on_close_dialogue):
		EventBus.close_dialogue.connect(_on_close_dialogue)

func _input(event: InputEvent) -> void:
	if not visible:
		return
 
	if event.is_action_pressed("ui_accept"):
		if _digitando:
			_pular_digitacao()
		else:
			EventBus.dialogue_advance.emit()
			
		get_viewport().set_input_as_handled()

# ==========================================
# ABRINDO O MONÓLOGO
# ==========================================
func _on_start_dialogue(data: Dictionary) -> void:
	get_tree().paused = true 
	visible = true
	
	# Agora ele pega APENAS o texto
	var texto : String = data.get("texto", "")
	_iniciar_digitacao(texto)

# ==========================================
# FECHANDO
# ==========================================
func _on_close_dialogue() -> void:
	get_tree().paused = false 
	visible = false
	texto_dialogo.text = ""
	_digitando = false
	if _tween_texto:
		_tween_texto.kill()

# ==========================================
# MÁQUINA DE ESCREVER
# ==========================================
func _iniciar_digitacao(texto: String) -> void:
	_digitando = true
	if _tween_texto:
		_tween_texto.kill()

	texto_dialogo.text = texto
	texto_dialogo.visible_ratio = 0.0

	var n_chars : int = texto_dialogo.get_total_character_count()
	var duracao : float = float(n_chars) / velocidade_texto

	_tween_texto = create_tween()
	_tween_texto.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS) 
	
	_tween_texto.tween_property(texto_dialogo, "visible_ratio", 1.0, duracao)\
				.set_ease(Tween.EASE_IN_OUT)\
				.set_trans(Tween.TRANS_LINEAR)
	_tween_texto.tween_callback(_ao_terminar_digitacao)

func _pular_digitacao() -> void:
	if _tween_texto:
		_tween_texto.kill()
	texto_dialogo.visible_ratio = 1.0
	_ao_terminar_digitacao()

func _ao_terminar_digitacao() -> void:
	_digitando = false
	EventBus.dialogue_line_finished.emit()
