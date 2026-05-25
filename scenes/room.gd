extends Node2D

# ==========================================
# MONÓLOGOS DO JULIO (EXCLUSIVOS DO QUARTO)
# ==========================================

# Fase 0: O jogo acabou de começar (New Game)
var pensamentos_inicio_jogo = [
	{ "texto": "Mais um dia... A luz do sol machuca meus olhos." },
	{ "texto": "Eu deveria levantar, mas o corpo pesa demais. Não tenho energia." },
	{ "texto": "Meus amigos me maltratam, sofro muito bullying, quebraram e roubaram meus brinquedos"},
	{ "texto": "Acho que vou dormir para esquecer isso..."}
]

# Fase 1: Ele acordou após passar pelo primeiro pesadelo
var pensamentos_apos_fase_1 = [
	{ "texto": "Aaah! ...Foi só um pesadelo. De novo." },
	{ "texto": "Eles estão cada vez mais frequentes"},
	{ "texto": "Aquelas sombras pareciam tão reais... Sinto que meu peito continua apertado." },
	{ "texto": "Será que um dia essa dor irá passar? Acho que eu deveria desistir de tudo..."}
]

# Fase 2: Ele acordou após passar pelo segundo pesadelo
var pensamentos_apos_fase_2 = [
	{ "texto": "Não dá para continuar assim, já sei o que fazer!" },
	{ "texto": "Tenho que mudar... Mudar minhas roupas, meu jeito, e meus pensamentos." },
	{ "texto": "Literalmente me transformar em outra pessoa!"}
]

# ==========================================
# GATILHO DA HISTÓRIA AO ENTRAR NO QUARTO
# ==========================================
func _ready() -> void:
	# call_deferred garante que a cena carregou 100% no motor antes de chamar o texto
	call_deferred("_checar_fase_do_quarto")

func _checar_fase_do_quarto() -> void:
	# O GameManager vai ditar em qual momento do jogo o Julio está
	match GameManager.fase_da_historia:
		0:
			# Primeiro despertar do Julio
			DialogueSequence.iniciar_cena(pensamentos_inicio_jogo)
			# Avança o estado para 1, assim, quando ele voltar do sonho, o jogo saberá que é o pós-pesadelo 1
			GameManager.fase_da_historia = 1 
			
		1:
			# Ele acabou de voltar do primeiro pesadelo
			DialogueSequence.iniciar_cena(pensamentos_apos_fase_1)
			# Avança para a próxima fase da história
			GameManager.fase_da_historia = 2
			
		2:
			# Ele acabou de voltar do segundo pesadelo
			DialogueSequence.iniciar_cena(pensamentos_apos_fase_2)
			# Avança para o estado final da história ou gameplay livre no quarto
			GameManager.fase_da_historia = 3
			
		_:
			# Se a fase for 3 ou maior, significa que ele já viu todos os monólogos principais ao acordar.
			# O quarto fica livre para gameplay sem caixas de texto automáticas.
			pass
