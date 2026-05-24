extends Area2D

@export var lifetime: float = 3.0
var velocity: Vector2 = Vector2.ZERO

func _ready() -> void:
	get_tree().create_timer(lifetime).timeout.connect(queue_free)
	
	if velocity != Vector2.ZERO:
		rotation = velocity.angle()
		
	# Conectando os sinais via código para garantir que funcionem
	# (Caso você não tenha conectado pelo painel verde do Godot)
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	position += velocity * delta

# ==========================================
# COLISÃO COM O CENÁRIO (Paredes, Chão)
# ==========================================
func _on_body_entered(body: Node2D) -> void:
	# Ignora se bater no próprio inimigo que atirou ou em outros inimigos
	if body is EnemyBase:
		return
		
	# Se bateu em qualquer outro Corpo Físico (como a parede), a bala some
	queue_free()

# ==========================================
# COLISÃO COM A HURTBOX DO JOGADOR
# ==========================================
func _on_area_entered(area: Area2D) -> void:
	# Pega o "Pai" da Hurtbox (O CharacterBody2D do Player)
	var parent = area.get_parent()
	
	# Checa se o pai existe, se é o Player e se pode tomar dano
	if parent and parent.is_in_group("player") and parent.has_method("Hurt"):
		parent.Hurt()
		queue_free()
