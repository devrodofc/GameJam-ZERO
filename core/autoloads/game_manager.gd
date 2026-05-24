extends Node

# ─── Enums ───────────────────────────────────────────────
enum Phase { DAY, NIGHT }

# ─── Estado global ───────────────────────────────────────
var current_phase: Phase = Phase.DAY
var current_day: int = 1

#1Morning.tscn
#1Night.tscn
#2Morning.tscn
#2Night.tscn
#3Morning.tscn
#3Night.tscn
#Créditos
#TitleScreen

# ─── Caminhos das cenas ──────────────────────────────────
# Mude este caminho se as suas cenas estiverem dentro de alguma pasta (ex: "res://Scenes/")
const BASE_SCENE_PATH: String = "res://scenes"

# Nomes exatos das telas avulsas
const SCENE_TITLE   = "TitleScreen.tscn"
const SCENE_CREDITS = "Creditos.tscn"

# ─── Sinais ──────────────────────────────────────────────
signal phase_changed(new_phase: Phase)
signal day_changed(new_day: int)

# ─── Começar o jogo (Chamado pelo botão Play da Title Screen) 
func start_game() -> void:
	current_day = 1
	current_phase = Phase.DAY
	_load_current_phase_scene()

# ─── Transição de Dia > Noite ────────────────────────────
func go_to_sleep() -> void:
	current_phase = Phase.NIGHT
	phase_changed.emit(current_phase)
	
	# Vai para [Dia]Night.tscn
	_load_current_phase_scene()

# ─── Transição de Noite > Próximo Dia ───────────────────
func wake_up() -> void:
	if current_day >= 3:
		_change_scene(BASE_SCENE_PATH + SCENE_CREDITS)
		return

	current_day += 1
	current_phase = Phase.DAY
	
	day_changed.emit(current_day)
	phase_changed.emit(current_phase)
	
	# Vai para [Novo Dia]Morning.tscn
	_load_current_phase_scene()

# ─── Lógica inteligente de carregamento ─────────────────
func _load_current_phase_scene() -> void:
	var phase_string = "Morning" if current_phase == Phase.DAY else "Night"
	var final_path = BASE_SCENE_PATH + str(current_day) + phase_string + ".tscn"
	
	_change_scene(final_path)

# ─── Troca de cena interna (com fade) ───────────────────
func _change_scene(path: String) -> void:
	if path == "":
		print("Aviso: Caminho da cena não definido!")
		return
		
	var fade = get_tree().root.find_child("FadeScreen", true, false)
	if fade and fade.has_method("fade_out"):
		await fade.fade_out()
		
	get_tree().change_scene_to_file(path)
