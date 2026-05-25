extends CharacterBody2D

signal memory_collected(memory_id: String)

@export_category("Story and Memories")
@export var All_memory_collected_text: String = "Todas as memórias foram recuperadas..."

@onready var camera = $Camera2D
@onready var Hearths_container = $Heaths
@onready var anim = $AnimatedSprite2D
@onready var force_bar : ProgressBar = $ProgressBar

@export_category("Life and combat")
@export var max_health := 6
@export var invincibility_duration: float = 1.5 
@export var hearth_scene: PackedScene

var current_health: int
var is_invincible: bool = false 
var collected_memories: Dictionary = {}

@export_category("Movement")
@export var speed: float = 300.0
@export_category("Movement")
@export var acceleration: float = 1500.0
@export_category("Movement")
@export var friction: float = 1200.0
var was_on_floor: bool = true
var last_velocity_y: float = 0.0

@export var jump_force: float = -450.0
@export var gravity: float = 980.0
@export var fall_gravity_multiplier: float = 1.5
@export var fast_fall_multiplier: float = 3.5

@export_category("Charged Air Jump")
@export var max_charge_force: float = 850.0   
@export var min_charge_force: float = 350.0   
@export_category("Charged Air Jump")
@export var charge_speed: float = 2.0         
@export_category("Charged Air Jump")
@export var float_fall_speed: float = 40.0    

var can_charge_jump: bool = false             
var is_charging: bool = false                 
var current_charge: float = 0.0               

var scale_tween: Tween 

@export var apex_hang_threshold: float = 100.0
@export var apex_hang_gravity_mult: float = 0.15 
@export var coyote_time: float = 0.1
@export var jump_buffer_time: float = 0.1

var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var is_jumping: bool = false

func _ready() -> void:
	current_health = max_health
	_initialize_hearts()
	if force_bar:
		force_bar.visible = false
		force_bar.min_value = 0.0
		force_bar.max_value = 1.0

func _physics_process(delta: float) -> void:
	var current_is_floor = is_on_floor()

	if current_is_floor and not was_on_floor:
		if last_velocity_y > 600.0:
			if camera and camera.has_method("add_trauma"):
				camera.add_trauma(0.2)

	if current_is_floor:
		coyote_timer = coyote_time
		can_charge_jump = true 
		is_jumping = false
		is_charging = false
		current_charge = 0.0
		if force_bar:
			force_bar.visible = false
	else:
		coyote_timer -= delta
		
	jump_buffer_timer -= delta
	
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time
		
	if not current_is_floor and can_charge_jump:
		if Input.is_action_just_pressed("jump") and coyote_timer <= 0:
			is_charging = true
			jump_buffer_timer = 0.0 
			if scale_tween and scale_tween.is_running():
				scale_tween.kill() 
			if force_bar:
				force_bar.visible = true

	if is_charging:
		if Input.is_action_pressed("jump"):
			current_charge = min(current_charge + (charge_speed * delta), 1.0)
			if force_bar:
				force_bar.value = current_charge
			
			velocity.y = float_fall_speed
			velocity.x = 0 
			
			var target_scale = lerp(4.0, 2.4, current_charge)
			anim.scale = Vector2(target_scale, target_scale)
			
		else:
			_execute_super_jump()

	if not current_is_floor and not is_charging:
		var applied_gravity = gravity
		
		if Input.is_action_pressed("look_down"):
			applied_gravity = gravity * fast_fall_multiplier
		elif velocity.y > 0: 
			applied_gravity = gravity * fall_gravity_multiplier

		if abs(velocity.y) < apex_hang_threshold and Input.is_action_pressed("jump") and not Input.is_action_pressed("look_down"):
			applied_gravity = gravity * apex_hang_gravity_mult
			
		velocity.y += applied_gravity * delta

	if jump_buffer_timer > 0 and coyote_timer > 0 and not is_charging:
		velocity.y = jump_force
		jump_buffer_timer = 0.0
		coyote_timer = 0.0
		is_jumping = true

	if Input.is_action_just_released("jump") and velocity.y < 0 and not is_charging:
		velocity.y *= 0.5 

	if not is_charging:
		var direction = Input.get_axis("move_left", "move_right")
		if direction != 0:
			velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, friction * delta)

	last_velocity_y = velocity.y

	move_and_slide()
	was_on_floor = current_is_floor
	_update_animations()

func _execute_super_jump() -> void:
	var charge_intensity = current_charge
	
	is_charging = false
	can_charge_jump = false 
	current_charge = 0.0
	is_jumping = true
	
	if force_bar:
		force_bar.visible = false
	
	var aim_direction = Input.get_vector("move_left", "move_right", "look_up", "look_down")
	if aim_direction == Vector2.ZERO:
		aim_direction = Vector2.UP
		
	var final_force = lerp(min_charge_force, max_charge_force, charge_intensity)
	velocity = aim_direction.normalized() * final_force
	
	if camera and camera.has_method("add_trauma"):
		camera.add_trauma(0.2 + (0.35 * charge_intensity))
		
	_animate_release_expansion(charge_intensity)

func _animate_release_expansion(charge_intensity: float) -> void:
	if scale_tween and scale_tween.is_running():
		scale_tween.kill()
		
	scale_tween = create_tween()
	
	var expansion_factor = lerp(4.4, 5.6, charge_intensity)
	scale_tween.tween_property(anim, "scale", Vector2(expansion_factor, expansion_factor), 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	scale_tween.tween_property(anim, "scale", Vector2(4.0, 4.0), 0.25).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

func _update_animations() -> void:
	if is_charging:
		anim.play("idle")
		return

	if abs(velocity.x) > 10.0:
		if velocity.x < 0:
			anim.play("walk_left")
		else:
			anim.play("walk_right")
	else:
		anim.play("idle")

func _initialize_hearts() -> void:
	if Hearths_container:
		for child in Hearths_container.get_children():
			child.queue_free()
			
		if hearth_scene:
			for i in range(current_health):
				var heart = hearth_scene.instantiate()
				Hearths_container.add_child(heart)

func Hurt() -> void:
	take_damage(1)

func take_damage(amount: int = 1) -> void:
	if current_health <= 0 or is_invincible:
		return 
		
	current_health = max(current_health - amount, 0)
	_update_hearts()
	
	if camera and camera.has_method("add_trauma"):
		camera.has_method("add_trauma")
		camera.add_trauma(0.5)
	
	if current_health == 0:
		die()
	else:
		trigger_iframes()

func trigger_iframes() -> void:
	is_invincible = true
	var tween = create_tween()
	var blink_count = int(invincibility_duration / 0.2)
	
	tween.set_loops(blink_count)
	tween.tween_property(self, "modulate:a", 0.3, 0.1)
	tween.tween_property(self, "modulate:a", 1.0, 0.1) 
	
	await get_tree().create_timer(invincibility_duration).timeout
	
	is_invincible = false
	modulate.a = 1.0

func _update_hearts() -> void:
	if Hearths_container:
		var hearts = Hearths_container.get_children()
		for i in range(hearts.size()):
			if i >= current_health:
				hearts[i].queue_free()

func collect_memory(memory_id: String) -> void:
	if not collected_memories.has(memory_id):
		collected_memories[memory_id] = true
		memory_collected.emit(memory_id)
		print("Memória guardada no Player: ", memory_id)
		
		if collected_memories.size() == 3:
			_show_final_memory_text()

func _show_final_memory_text() -> void:
	await get_tree().create_timer(3.0).timeout
	
	var final_label = Label.new()
	final_label.text = All_memory_collected_text
	final_label.add_theme_color_override("font_color", Color.AQUA)
	final_label.add_theme_font_size_override("font_size", 24)
	
	final_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	final_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	final_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	
	add_child(final_label)
	final_label.position = Vector2(0, -120.0)
	
	var text_tween = final_label.create_tween()
	text_tween.tween_property(final_label, "position:y", final_label.position.y - 50.0, 4.0).set_ease(Tween.EASE_OUT)
	text_tween.parallel().tween_property(final_label, "modulate:a", 0.0, 4.0).set_ease(Tween.EASE_IN).set_delay(2.0)
	text_tween.tween_callback(final_label.queue_free)
	await get_tree().create_timer(5.0).timeout
	GameManager.wake_up()

func die() -> void:
	print("Player morreu!")
	get_tree().call_deferred("reload_current_scene")
