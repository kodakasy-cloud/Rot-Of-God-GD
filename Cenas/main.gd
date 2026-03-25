extends Node2D

@export var item_scene: PackedScene 

func _can_drop_data(_at_position: Vector2, data) -> bool:
	# Só aceita se for uma String (nome do item)
	return typeof(data) == TYPE_STRING

func _drop_data(_at_position: Vector2, data) -> void:
	print("Tentando dropar: ", data)
	
	if item_scene == null:
		print("ERRO CRÍTICO: Você não arrastou o item.tscn para o Inspector do nó Main!")
		return

	# 1. Tira do inventário
	InventoryManager.remove_item(data, 1)
	
	# 2. Cria o objeto
	var drop = item_scene.instantiate()
	
	# 3. Configura o objeto
	drop.item_name = data
	
	# 4. Adiciona ao mundo ANTES de definir a posição
	add_child(drop)
	
	# 5. Define a posição (Garante que o Z-Index seja alto para aparecer na frente)
	drop.global_position = get_global_mouse_position()
	drop.z_index = 10 
	
	print("Item dropado com sucesso em: ", drop.global_position)
