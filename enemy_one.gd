extends CharacterBody2D

# --- CONFIGURAÇÕES ---
@export var speed: float = 150.0
@export var acceleration: float = 5.0
@export var max_health: int = 10
var current_health: int = max_health

# --- NOVA LÓGICA DE ÓRBITA ---
var orbit_direction: int = 1 # 1 para horário, -1 para anti-horário
var change_orbit_time: float = 2.0 # Tempo para trocar de lado

# --- REFERÊNCIAS ---
var player: CharacterBody2D = null
var is_in_attack_range: bool = false

@onready var health_bar: ProgressBar = $HealthBar
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	add_to_group("Enemy")
	
	# Resolve o problema de brilhar em todos ao mesmo tempo
	if sprite and sprite.material:
		sprite.material = sprite.material.duplicate()
		
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = current_health
	
	# Inicia o ciclo de mudar a direção da órbita
	_start_orbit_timer()

func _physics_process(delta: float) -> void:
	if player:
		var target_pos = player.global_position
		var direction_to_player = global_position.direction_to(target_pos)
		
		if is_in_attack_range:
			# LÓGICA DE ÓRBITA ALEATÓRIA
			# Multiplicamos pela 'orbit_direction' (1 ou -1)
			var orbit_dir = Vector2(-direction_to_player.y, direction_to_player.x) * orbit_direction
			velocity = velocity.lerp(orbit_dir * speed, acceleration * delta)
		else:
			# Lógica de perseguir
			velocity = velocity.lerp(direction_to_player * speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, speed * delta)

	move_and_slide()

# --- FUNÇÃO PARA MUDAR A DIREÇÃO DA ÓRBITA ---
func _start_orbit_timer() -> void:
	# Escolhe um tempo aleatório entre 1.5 e 4 segundos para mudar de lado
	await get_tree().create_timer(randf_range(1.5, 4.0)).timeout
	
	# Inverte a direção (se era 1 vira -1, se era -1 vira 1)
	orbit_direction *= -1
	
	# Reinicia o ciclo (Recursividade)
	_start_orbit_timer()

# --- FUNÇÃO DE DANO ---
func take_damage(amount: int) -> void:
	current_health -= amount
	if health_bar:
		health_bar.value = current_health
	
	# Brilho individual
	if sprite and sprite.material:
		sprite.material.set_shader_parameter("flash_modifier", 1.0)
		await get_tree().create_timer(0.1).timeout
		sprite.material.set_shader_parameter("flash_modifier", 0.0)
	
	if current_health <= 0:
		die()

func die() -> void:
	queue_free()

# --- SINAIS ---
func _on_detection_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"): player = body

func _on_detection_range_body_exited(body: Node2D) -> void:
	if body == player: player = null

func _on_attack_range_body_entered(body: Node2D) -> void:
	if body == player: is_in_attack_range = true

func _on_attack_range_body_exited(body: Node2D) -> void:
	if body == player: is_in_attack_range = false