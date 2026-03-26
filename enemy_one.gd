extends CharacterBody2D

# --- CONFIGURAÇÕES ---
@export var speed: float = 150.0
@export var acceleration: float = 5.0
@export var max_health: int = 10
@export var moeda_scene: PackedScene # <--- NOVO: Arraste a moeda.tscn aqui no Inspector
var current_health: int = max_health

# --- NOVA LÓGICA DE ÓRBITA ---
var orbit_direction: int = 1 # 1 para horário, -1 para anti-horário
var change_orbit_time: float = 2.0

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
	await get_tree().create_timer(randf_range(1.5, 4.0)).timeout
	orbit_direction *= -1
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

# --- NOVA LÓGICA DE MORTE E DROP ---
func die() -> void:
	drop_item() # Chama o drop antes de morrer
	queue_free()

func drop_item() -> void:
	# 1. Checa a chance de drop (0.4 = 40%)
	var sorteio = randf()
	if sorteio > 0.4:
		print("Azar! O inimigo não dropou nada desta vez.")
		return # Sai da função e não spawna nada

	# 2. Se passou na chance, verifica se a cena existe
	if moeda_scene:
		var nova_moeda = moeda_scene.instantiate()
		
		# 3. Define a quantidade aleatória entre 3 e 5
		# Importante: Sua moeda precisa ter a variável 'amount' no script dela!
		var quantidade_aleatoria = randi_range(30, 50)
		nova_moeda.amount = quantidade_aleatoria
		
		# 4. Adiciona ao mundo
		get_tree().current_scene.add_child(nova_moeda)
		nova_moeda.global_position = global_position
		nova_moeda.z_index = 1
		
		print("Drop de sorte! Criada moeda com valor: ", quantidade_aleatoria)
	else:
		print("Erro: Moeda Scene não configurada no Inspector!")

# --- SINAIS ---
func _on_detection_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"): player = body

func _on_detection_range_body_exited(body: Node2D) -> void:
	if body == player: player = null

func _on_attack_range_body_entered(body: Node2D) -> void:
	if body == player: is_in_attack_range = true

func _on_attack_range_body_exited(body: Node2D) -> void:
	if body == player: is_in_attack_range = false