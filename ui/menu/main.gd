extends Control

# --- REFERÊNCIAS DOS GRUPOS DE BOTÕES ---
@onready var main_buttons: VBoxContainer = $MarginContainer/MainBtns
@onready var options_buttons: VBoxContainer = $MarginContainer/OptionsBtns
@onready var back_button: TextureButton = $BtnBack
@onready var credits_container: VBoxContainer = $CreditsContainer
@onready var controles_container: VBoxContainer = $ControlesContainer
@onready var logo: Sprite2D = $Logo

func _ready() -> void:
	# Garante que o menu comece no estado correto
	_show_main_menu()

# --- FUNÇÕES DE TRANSIÇÃO (ESTADOS) ---

func _show_main_menu() -> void:
	main_buttons.show()
	options_buttons.hide()
	back_button.hide()
	credits_container.hide()
	controles_container.hide()
	logo.show()

func _show_options_menu() -> void:
	main_buttons.hide()
	options_buttons.show()
	back_button.show()
	credits_container.hide()
	controles_container.hide()
	logo.show()
	
func _show_credits_menu() -> void:
	main_buttons.hide()
	options_buttons.hide()
	back_button.show()
	credits_container.show()
	controles_container.hide()
	logo.hide()
	
func _show_controles_menu() -> void:
	main_buttons.hide()
	options_buttons.hide()
	back_button.show()
	credits_container.hide()
	controles_container.show()
	logo.hide()

# --- SINAIS DOS BOTÕES (Ações) ---

func _on_btn_options_pressed() -> void:
	_show_options_menu()

func _on_btn_credits_pressed() -> void:
	_show_credits_menu()
	
func _on_btn_controles_pressed() -> void:
	_show_controles_menu()
	
func _on_btn_back_pressed() -> void:
	if credits_container.visible or controles_container.visible:
		_show_options_menu()
	elif options_buttons.visible:
		_show_main_menu()

func _on_btn_start_pressed() -> void:
	main_buttons.mouse_filter = Control.MOUSE_FILTER_IGNORE
	GameManager.start_game() 

func _on_btn_quit_pressed() -> void:
	get_tree().quit()
