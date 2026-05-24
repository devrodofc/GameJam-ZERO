extends Area2D

# ─── Exportáveis (configuráveis pelo editor) ─────────────
@export var memory_id: String = ""
@export var dialogue_lines: Array[String] = []

# ─── Nós filhos ──────────────────────────────────────────
@onready var label: Label = $InteractLabel

var _player_nearby: bool = false

func _ready() -> void:
	label.visible = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _unhandled_input(event: InputEvent) -> void:
	if _player_nearby and event.is_action_pressed("interact"):
		_examine()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_player_nearby = true
		label.visible = true

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		_player_nearby = false
		label.visible = false

func _examine() -> void:
	# Registra memória no GameManager
	if memory_id != "":
		GameManager.collect_memory(memory_id)

	# Envia diálogo para a DialogueBox da cena pai
	var dialogue = get_tree().root.find_child("DialogueBox", true, false)
	if dialogue:
		dialogue.show_lines(dialogue_lines)
		
