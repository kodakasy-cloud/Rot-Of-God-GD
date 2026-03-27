extends Node2D

@export var item_scene: PackedScene 

func _can_drop_data(_at_position: Vector2, data) -> bool:
	# Agora o 'data' é o dicionário do item que veio do slot
	return typeof(data) == TYPE_DICTIONARY and data.has("name")

func _drop_data(_at_position: Vector2, data) -> void:
	# 'data' contém: {"name": "moeda", "amount": 100, "texture": ...}
	var item_nome = data["name"]
	var item_qtd = data["amount"]
	
	print("Tentando dropar pilha de: ", item_nome, " Quantidade: ", item_qtd)
	
	if item_scene == null:
		print("ERRO: item_scene (moeda.tscn) não configurada no Mapa!")
		return

	# 1. Remove a quantidade EXATA que estava naquele slot do inventário
	InventoryManager.remove_item(item_nome, item_qtd)
	
	# 2. Cria o objeto no mundo
	var drop = item_scene.instantiate()
	
	# 3. Configura o objeto ANTES de adicionar à árvore (importante)
	drop.item_name = item_nome
	drop.amount = item_qtd # Define que esse drop vale o total da pilha
	
	# 4. Adiciona ao mundo
	add_child(drop)
	
	# 5. Posicionamento e Visual
	drop.global_position = get_global_mouse_position()
	drop.z_index = 10 
	
	# Opcional: Se for uma pilha grande, podemos aumentar o tamanho visual do drop
	if item_qtd >= 100:
		drop.scale = Vector2(1.5, 1.5) # Deixa o drop maior se for uma pilha cheia
	
	print("Pilha de ", item_qtd, " dropada com sucesso!")