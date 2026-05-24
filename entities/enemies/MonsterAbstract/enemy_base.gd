class_name EnemyBase
extends CharacterBody2D

@onready var hitbox: Area2D = get_node_or_null("Hitbox")
@onready var color_rect: ColorRect = get_node_or_null("ColorRect")

@export var color: Color = Color(1, 1, 1) # Branco por padrão
@export var max_health: int = 1

var current_health: int
var is_dead: bool = false

# ==========================================
# INICIALIZAÇÃO BASE
# ==========================================
func _ready() -> void:
	current_health = max_health
	
	# MUDANÇA AQUI: Aplica a cor ao ColorRect assim que o inimigo nasce
	if color_rect:
		color_rect.color = color
	else:
		push_warning("Atenção: O inimigo '" + name + "' não possui um nó 'ColorRect'!")
	
	if hitbox:
		hitbox.area_entered.connect(_on_hitbox_area_entered)
		hitbox.body_entered.connect(_on_hitbox_body_entered)
	else:
		push_warning("Atenção: O inimigo '" + name + "' não possui um nó chamado 'Hitbox'!")

# ==========================================
# CAUSAR DANO (CASO BATA NA HURTBOX - AREA2D)
# ==========================================
func _on_hitbox_area_entered(area: Area2D) -> void:
	if is_dead:
		return
		
	var parent = area.get_parent()
	if parent and parent.is_in_group("player") and parent.has_method("Hurt"):
		parent.Hurt()

# ==========================================
# CAUSAR DANO (CASO BATA DIRETO NO CORPO - CHARACTERBODY2D)
# ==========================================
func _on_hitbox_body_entered(body: Node2D) -> void:
	if is_dead:
		return
		
	if body.is_in_group("player") and body.has_method("Hurt"):
		body.Hurt()

# ==========================================
# RECEBER DANO (Para o inimigo poder morrer)
# ==========================================
func take_damage(amount: int = 1) -> void:
	if is_dead:
		return
		
	current_health -= amount
	
	# Game Juice: Pisca em vermelho ao tomar dano
	# (O modulate afeta todo o CharacterBody2D, incluindo o ColorRect, então funciona perfeitamente!)
	modulate = Color(1, 0, 0)
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1), 0.2)
	
	if current_health <= 0:
		die()

# ==========================================
# MÉTODO COMUM: MORTE E ANIMAÇÃO
# ==========================================
func die() -> void:
	if is_dead: return
	
	is_dead = true
	set_physics_process(false)
	
	# Desabilita as colisões do corpo principal
	if has_node("CollisionShape2D"):
		$CollisionShape2D.set_deferred("disabled", true)
		
	# Desabilita as colisões da Hitbox (usando a variável que já temos)
	if hitbox and hitbox.has_node("CollisionShape2D"):
		hitbox.get_node("CollisionShape2D").set_deferred("disabled", true)
	
	# Animação de morte
	var tween = create_tween()
	tween.tween_property(self, "velocity", Vector2.ZERO, 0.2)
	tween.tween_property(self, "modulate:a", 0.0, 0.6)
	tween.parallel().tween_property(self, "position:y", position.y - 40.0, 0.6).set_ease(Tween.EASE_OUT)
	tween.tween_callback(queue_free)
