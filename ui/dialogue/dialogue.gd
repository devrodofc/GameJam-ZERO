extends CanvasLayer

@onready var text_label: Label     = $Panel/Label
@onready var hint: Label           = $Panel/ContinueHint

var _lines: Array[String] = []
var _current: int = 0

func _ready() -> void:
	visible = false

func show_lines(lines: Array[String]) -> void:
	_lines = lines
	_current = 0
	visible = true
	_display_current()
	get_tree().paused = true   # pausa o jogo durante o diálogo

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("skip_dialogue"):
		_advance()

func _advance() -> void:
	_current += 1
	if _current >= _lines.size():
		_close()
	else:
		_display_current()

func _display_current() -> void:
	text_label.text = _lines[_current]

func _close() -> void:
	visible = false
	_lines.clear()
	get_tree().paused = false  # retoma o jogo
