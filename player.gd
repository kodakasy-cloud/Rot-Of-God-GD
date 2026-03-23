extends CharacterBody2D

# Criamos uma constante para a velocidade, assim fica fácil de mudar depois
const SPEED = 300.0

func _physics_process(_delta):
	# 1. Capturamos a direção baseada nas setas do teclado ou WASD (padrão da Godot)
	# O get_vector devolve um Vector2 (x, y) variando de -1 a 1
	var direction = Input.get_vector("mov_left", "mov_right", "mov_up", "mov_down")
	
	# 2. Se houver alguma tecla pressionada (direção diferente de zero)
	if direction:
		# Atualizamos a variável interna 'velocity' com a direção * velocidade
		velocity = direction * SPEED
	else:
		# Se soltar as teclas, a velocidade vai para zero suavemente ou de vez
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)

	# 3. A função mágica que faz o movimento e trata colisões
	move_and_slide()