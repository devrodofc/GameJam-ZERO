extends Node

var sequencia_atual: Array = []
var indice_atual: int = 0

func _ready() -> void:
	# Conecta o sinal de avanço do jogador para puxar a próxima linha
	EventBus.dialogue_advance.connect(_proxima_linha)

# Função que as fases (como o quarto) vão chamar para começar uma história
func iniciar_cena(cena: Array) -> void:
	if cena.is_empty(): 
		return
	
	sequencia_atual = cena
	indice_atual = 0
	_tocar_linha_atual()

func _proxima_linha() -> void:
	indice_atual += 1
	if indice_atual < sequencia_atual.size():
		_tocar_linha_atual()
	else:
		# Se as linhas acabaram, avisa a interface visual para fechar
		EventBus.close_dialogue.emit()

func _tocar_linha_atual() -> void:
	var linha = sequencia_atual[indice_atual]
	EventBus.start_dialogue.emit(linha)
