extends Area2D

@export var enemy_scene: PackedScene # Arraste o seu enemy_one.tscn aqui
@export var max_enemies: int = 5

@onready var collision_shape = $CollisionShape2D
@onready var timer = $Timer

func _ready() -> void:
    # Garante que o timer esteja rodando
    if timer.is_stopped():
        timer.start()

func _on_timer_timeout() -> void:
    # Conta quantos inimigos do grupo "Enemy" existem na cena inteira
    var total_enemies = get_tree().get_nodes_in_group("Enemy").size()
    
    # Se houver menos que o limite, spawna um
    if total_enemies < max_enemies:
        spawn_enemy_in_area()

func spawn_enemy_in_area() -> void:
    if not enemy_scene:
        print("Erro: enemy_scene não configurada no Spawner!")
        return
        
    var enemy = enemy_scene.instantiate()
    
    # Pega o retângulo da colisão
    var rect = collision_shape.shape.get_rect()
    
    # Gera uma posição aleatória dentro dos limites do retângulo
    var random_pos = Vector2(
        randf_range(rect.position.x, rect.position.x + rect.size.x),
        randf_range(rect.position.y, rect.position.y + rect.size.y)
    )
    
    # Ajusta para a posição global do Spawner
    enemy.global_position = global_position + random_pos
    
    # Adiciona à cena principal (root)
    get_tree().root.add_child(enemy)