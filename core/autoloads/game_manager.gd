extends Node

# ─── Enums ───────────────────────────────────────────────
enum Phase { DAY, NIGHT }

# ─── Estado global ───────────────────────────────────────
var current_phase: Phase = Phase.DAY
var current_day: int = 1
var fase_da_historia: int = 0

# ─── Caminhos das cenas ──────────────────────────────────
const BASE_SCENE_PATH: String = "res://scenes/"

const SCENE_DAY     = "room.tscn"
const SCENE_NIGHT   = "dream.tscn"
const SCENE_TITLE   = "TitleScreen.tscn"
const SCENE_CREDITS = "Creditos.tscn"

# ─── Sinais ──────────────────────────────────────────────
signal phase_changed(new_phase: Phase)
signal day_changed(new_day: int)

# ─── Começar o jogo ──────────────────────────────────────
func start_game() -> void:
	current_day = 1
	current_phase = Phase.DAY
	fase_da_historia = 0 
	_load_current_phase_scene()

# ─── Transição de Dia > Noite ────────────────────────────
func go_to_sleep() -> void:
	current_phase = Phase.NIGHT
	phase_changed.emit(current_phase)
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
	
	_load_current_phase_scene()

# ─── Lógica de carregamento fixo ────────────────────────
func _load_current_phase_scene() -> void:
	# Agora ele só escolhe entre room.tscn e dream.tscn
	var target_scene = SCENE_DAY if current_phase == Phase.DAY else SCENE_NIGHT
	var final_path = BASE_SCENE_PATH + target_scene
	
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
