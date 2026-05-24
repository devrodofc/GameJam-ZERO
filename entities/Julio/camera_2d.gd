extends Camera2D

@export_group("Screen Shake")
@export var trauma_reduction_rate: float = 1.0
@export var max_offset: Vector2 = Vector2(25.0, 25.0)
@export var max_roll: float = 0.1
@export var noise_speed: float = 50.0

var trauma: float = 0.0
var time: float = 0.0
var shake_offset: Vector2 = Vector2.ZERO

@onready var noise := FastNoiseLite.new()

func _ready() -> void:
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN

	position_smoothing_enabled = true
	position_smoothing_speed = 5.0

func _physics_process(delta: float) -> void:
	if trauma > 0.0:
		time += delta * noise_speed
		trauma = max(trauma - trauma_reduction_rate * delta, 0.0)
		_apply_shake()
	else:
		shake_offset = Vector2.ZERO
		rotation = 0.0

	offset = shake_offset

func add_trauma(amount: float) -> void:
	trauma = min(trauma + amount, 1.0)

func _apply_shake() -> void:
	var shake_amount = trauma * trauma

	shake_offset.x = max_offset.x * shake_amount * noise.get_noise_2d(time, 0.0)
	shake_offset.y = max_offset.y * shake_amount * noise.get_noise_2d(time, 100.0)

	rotation = max_roll * shake_amount * noise.get_noise_2d(time, 200.0)
