extends Control

# --- REFERÊNCIAS DOS GRUPOS DE BOTÕES ---
@onready var main_buttons: VBoxContainer = $MarginContainer/MainBtns
@onready var options_buttons: VBoxContainer = $MarginContainer/OptionsBtns
@onready var back_button: TextureButton = $BtnBack

func _ready() -> void:
	# Garante que o menu comece no estado correto
	_show_main_menu()

# --- FUNÇÕES DE TRANSIÇÃO (ESTADOS) ---

func _show_main_menu() -> void:
	options_buttons.hide() # Esconde as opções
	back_button.hide()
	main_buttons.show()    # Mostra o menu principal

func _show_options_menu() -> void:
	main_buttons.hide()    # Esconde o menu principal
	back_button.show()
	options_buttons.show() # Mostra as opções

# --- SINAIS DOS BOTÕES (Ações) ---

func _on_btn_options_pressed() -> void:
	_show_options_menu()

func _on_btn_back_pressed() -> void:
	_show_main_menu()

func _on_btn_start_pressed() -> void:
	main_buttons.mouse_filter = Control.MOUSE_FILTER_IGNORE
	GameManager.start_game() 

func _on_btn_quit_pressed() -> void:
	get_tree().quit()
