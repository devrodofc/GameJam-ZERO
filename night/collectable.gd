extends Area2D

# ==========================================
# CONFIGURAÇÕES DA MEMÓRIA
# ==========================================
@export var memory_id: String = "memoria_1"

var is_collected: bool = false

# ==========================================
# INICIALIZAÇÃO
# ==========================================
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
	var float_tween = create_tween().set_loops()
	float_tween.tween_property(self, "position:y", position.y - 5.0, 1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	float_tween.tween_property(self, "position:y", position.y, 1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)


# ==========================================
# COLETA
# ==========================================
func _on_body_entered(body: Node2D) -> void:
	if is_collected:
		return
		
	if body.is_in_group("player"):
		is_collected = true
		
		if GameManager.has_method("collect_memory"):
			GameManager.collect_memory(memory_id)
			print("Memória coletada: ", memory_id)
		else:
			push_warning("AutoLoad Global deu pau!")
			
		if has_node("CollisionShape2D"):
			$CollisionShape2D.set_deferred("disabled", true)
			
		var tween = create_tween()
		tween.tween_property(self, "position:y", position.y - 30.0, 0.4).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(self, "modulate:a", 0.0, 0.4)
		tween.tween_callback(queue_free)
