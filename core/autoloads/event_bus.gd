extends Node

# ==========================================
# SINAIS GLOBAIS DE DIÁLOGO
# ==========================================
# Disparado para começar a escrever um texto na tela
signal start_dialogue(data: Dictionary)

# Disparado para fechar a caixa visual de diálogo
signal close_dialogue()

# Disparado quando o jogador aperta a tecla de avançar (Espaço/Enter)
signal dialogue_advance()

# Disparado automaticamente quando a animação de digitar as letras termina
signal dialogue_line_finished()
