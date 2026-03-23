extends CharacterBody2D

const SPEED = 300.0
const BALA_CENA = preload("res://bala.tscn")

# --- NOVAS VARIÁVEIS PARA O TIRO ---
var pode_atirar = true # A "trava" de segurança
const COOLDOWN = 0.4   # Tempo de espera entre os tiros

func _physics_process(_delta):
	# Movimentação
	var direction = Input.get_vector("mov_left", "mov_right", "mov_up", "mov_down")
	velocity = direction * SPEED
	move_and_slide()

	# --- LÓGICA DE ATIRAR SEGURANDO ---
	# Trocamos 'is_action_just_pressed' por 'is_action_pressed'
	if Input.is_action_pressed("atirar") and pode_atirar:
		atirar()

func atirar():
	# 1. Ativa a trava imediatamente
	pode_atirar = false
	
	# 2. Cria e configura a bala (mesmo código de antes)
	var nova_bala = BALA_CENA.instantiate()
	nova_bala.global_position = self.global_position
	var direcao_mouse = (get_global_mouse_position() - global_position).normalized()
	nova_bala.direcao = direcao_mouse
	nova_bala.rotation = direcao_mouse.angle() + PI/2
	get_parent().add_child(nova_bala)
	
	# 3. CRIA O TIMER VIA CÓDIGO
	# Isso cria um cronômetro invisível que dura 0.4 segundos
	await get_tree().create_timer(COOLDOWN).timeout
	
	# 4. Libera a trava após o tempo passar
	pode_atirar = true