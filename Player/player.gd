extends CharacterBody2D

# Carrega a cena da bala com o nome que você definiu
const BALA_PROJECT = preload("res://Player/project_player.tscn") 

@export var speed: float = 250.0
@export var fire_rate: float = 0.2
var can_fire: bool = true

func _physics_process(_delta: float) -> void:
	# Movimentação WASD
	var input_dir := Input.get_vector("mov_left", "mov_right", "mov_up", "mov_down")
	velocity = input_dir * speed
	move_and_slide()

func _process(_delta: float) -> void:
	# Atirar ao segurar o mouse (Ação: atirar)
	if Input.is_action_pressed("atirar") and can_fire:
		shoot()

func shoot() -> void:
	can_fire = false
	
	# Instancia a bala (project_player)
	var bala = BALA_PROJECT.instantiate()
	
	# Define posição e direção para o mouse
	bala.global_position = global_position
	var mouse_direction = (get_global_mouse_position() - global_position).normalized()
	bala.direction = mouse_direction
	bala.rotation = mouse_direction.angle()
	
	# Adiciona no mundo (root) para não seguir o movimento do player
	get_tree().root.add_child(bala)
	
	# Espera 0.3 segundos para o próximo tiro
	await get_tree().create_timer(fire_rate).timeout
	can_fire = true