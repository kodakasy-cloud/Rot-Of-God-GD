extends Node

const MAX_SLOTS = 10
const MAX_STACK = 100

# Agora vamos usar uma Array de Dicionários para controlar a ordem e os slots
var inventory: Array = []

func add_item(item_name: String, item_tex: Texture2D, amount: int):
	# 1. Tenta encontrar uma pilha existente que NÃO esteja cheia
	for slot in inventory:
		if slot["name"] == item_name and slot["amount"] < MAX_STACK:
			var space_left = MAX_STACK - slot["amount"]
			var to_add = min(amount, space_left)
			
			slot["amount"] += to_add
			amount -= to_add # Subtrai o que já guardamos
			
			if amount <= 0:
				emit_signal("inventory_updated")
				return # Guardamos tudo!

	# 2. Se sobrou algo (ou o item não existia), tentamos criar novos slots
	while amount > 0:
		if inventory.size() < MAX_SLOTS:
			var to_add = min(amount, MAX_STACK)
			inventory.append({
				"name": item_name,
				"texture": item_tex,
				"amount": to_add
			})
			amount -= to_add
		else:
			print("Inventário Totalmente Lotado! Perdeu o resto.")
			break # Não há mais espaço em nenhum slot

	emit_signal("inventory_updated")

func remove_item(item_name: String, amount: int):
	# Remove dos slots (começando pelo último para ser mais lógico)
	for i in range(inventory.size() - 1, -1, -1):
		if inventory[i]["name"] == item_name:
			if inventory[i]["amount"] > amount:
				inventory[i]["amount"] -= amount
				amount = 0
				break
			else:
				amount -= inventory[i]["amount"]
				inventory.remove_at(i)
		if amount <= 0: break
	
	emit_signal("inventory_updated")

signal inventory_updated # Adicione este sinal no topo se não tiver