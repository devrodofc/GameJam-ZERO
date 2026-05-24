extends Area2D

# ==========================================
# CONFIGURAÇÕES DA MEMÓRIA
# ==========================================
@export var memory_id: String = "memoria_1"
@export var description: String = "..."

@export_group("Visual")
@export var memory_icon: Texture2D 
@export var float_height: float = 5.0 

@export_group("Configurações do Texto")
@export var text_color: Color = Color.WHITE
@export var font_size: int = 32
@export var text_offset_y: float = 100.0 
@export var text_offset_x: float = -300.0

@onready var texture_rect: TextureRect = $Sprite

var is_collected: bool = false

# ==========================================
# INICIALIZAÇÃO
# ==========================================
func _ready() -> void:
	if memory_icon and texture_rect:
		texture_rect.texture = memory_icon
		
	body_entered.connect(_on_body_entered)
	
	var float_tween = create_tween().set_loops()
	float_tween.tween_property(self, "position:y", position.y - float_height, 1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	float_tween.tween_property(self, "position:y", position.y, 1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

# ==========================================
# COLETA
# ==========================================
func _on_body_entered(body: Node2D) -> void:
	if is_collected:
		return
		
	if body.is_in_group("player"):
		is_collected = true
		
		# MUDANÇA AQUI: Agora a memória é injetada diretamente no Player (body)
		if body.has_method("collect_memory"):
			body.collect_memory(memory_id)
		else:
			push_warning("Atenção: O Player tocou no item, mas não tem a função 'collect_memory'!")
			
		if has_node("CollisionShape2D"):
			$CollisionShape2D.set_deferred("disabled", true)
			
		# ------------------------------------------------------------------
		# TEXTO FLUTUANTE (SEGUE O JOGADOR)
		# ------------------------------------------------------------------
		var popup_label = Label.new()
		popup_label.text = description
		
		popup_label.add_theme_color_override("font_color", text_color)
		popup_label.add_theme_font_size_override("font_size", font_size)
		
		popup_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		popup_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		popup_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
		
		# O texto vira filho do Player (body) para seguir ele
		body.add_child(popup_label)
		
		popup_label.position = Vector2(text_offset_x, -text_offset_y)
		
		# Animação do texto subindo
		var text_tween = popup_label.create_tween()
		text_tween.tween_property(popup_label, "position:y", popup_label.position.y - 60.0, 2.0).set_ease(Tween.EASE_OUT)
		text_tween.parallel().tween_property(popup_label, "modulate:a", 0.0, 2.0).set_ease(Tween.EASE_IN)
		text_tween.tween_callback(popup_label.queue_free)
		# ------------------------------------------------------------------
			
		# Animação do item sumindo
		var tween = create_tween()
		tween.tween_property(self, "position:y", position.y - 30.0, 0.4).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(self, "modulate:a", 0.0, 0.4)
		tween.tween_callback(queue_free)
