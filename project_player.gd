extends Area2D

@export var speed: float = 600.0
@export var damage: int = 2
var direction: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	# Move a bala
	position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	# Verifica se quem foi atingido está no grupo Enemy
	if body.is_in_group("Enemy"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free() # Destrói a bala ao colidir com o inimigo
	
	# Destrói a bala se bater em paredes, mas ignora o Atirador (Player)
	elif not body.is_in_group("Player"):
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free() # Limpa da memória se sair da tela