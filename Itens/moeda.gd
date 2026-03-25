extends Area2D

@export var item_name: String = "Moeda"
@export var amount: int = 1

@onready var sprite: Sprite2D = $Sprite2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		collect()

func collect() -> void:
	if sprite and sprite.texture:
		var item_tex = sprite.texture
		
		# O ERRO ESTAVA AQUI: Faltava o 'item_name' antes do 'item_tex'
		InventoryManager.add_item(item_name, item_tex, int(amount))
		
		print("Coletou: ", item_name)
		queue_free()
	else:
		print("Erro: Sprite ou textura ausente!")
