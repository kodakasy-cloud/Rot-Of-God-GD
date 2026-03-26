extends Area2D

@export var item_name: String = "Moeda"
@export var amount: int = 1

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	# Garante que o sinal de colisão esteja conectado por código 
	# (caso você esqueça de conectar no nó Area2D)
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		collect()

func collect() -> void:
	# Verificamos se o Sprite e a Textura existem
	if sprite and sprite.texture:
		var item_tex = sprite.texture
		
		# Enviamos os dados para o InventoryManager
		# O int(amount) evita erros de tipo caso o valor venha do Inspector
		InventoryManager.add_item(item_name, item_tex, int(amount))
		
		print("Coletou: ", item_name, " (x", amount, ")")
		queue_free() # Remove a moeda do mundo
	else:
		# Se você esqueceu de colocar uma imagem na moeda, este erro avisa:
		print("Erro: A moeda '", item_name, "' não tem uma textura no Sprite2D!")