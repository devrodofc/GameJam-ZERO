extends Node

# ─── Enums ───────────────────────────────────────────────
enum Phase { DAY, NIGHT }

# ─── Estado global ───────────────────────────────────────
var current_phase: Phase = Phase.DAY
var current_night: int = 1
var collected_memories: Dictionary = {}

# ─── Caminhos das cenas ──────────────────────────────────
# Deixaremos vazios por enquanto, preencheremos na Sprint 3
const SCENE_DAY   = "res://day/room.tscn"
const SCENE_NIGHT = "res://night/dream.tscn"

# ─── Sinais ──────────────────────────────────────────────
signal phase_changed(new_phase: Phase)
signal night_changed(new_night: int)
signal memory_collected(memory_id: String)

# ─── Transição de Dia → Noite ────────────────────────────
func go_to_sleep() -> void:
	current_phase = Phase.NIGHT
	phase_changed.emit(current_phase)
	_change_scene(SCENE_NIGHT)

# ─── Transição de Noite → Próximo Dia ───────────────────
func wake_up() -> void:
	if current_night < 3:
		current_night += 1
		night_changed.emit(current_night)

	current_phase = Phase.DAY
	phase_changed.emit(current_phase)
	_change_scene(SCENE_DAY)

# ─── Registrar memória coletada ─────────────────────────
func collect_memory(memory_id: String) -> void:
	if not collected_memories.has(memory_id):
		collected_memories[memory_id] = true
		memory_collected.emit(memory_id)

# ─── Checar se Julio está pronto para vencer ────────────
func is_ready_to_win() -> bool:
	return collected_memories.size() > 2 #Mudar de 0 para 2

# ─── Troca de cena interna (com fade) ───────────────────
func _change_scene(path: String) -> void:
	if path == "":
		print("Aviso: Caminho da cena não definido!")
		return
		
	var fade = get_tree().root.find_child("FadeScreen", true, false)
	if fade and fade.has_method("fade_out"):
		await fade.fade_out()
		
	get_tree().change_scene_to_file(path)
