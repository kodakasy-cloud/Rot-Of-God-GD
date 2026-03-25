extends Node

# Estrutura: "Nome": {"quantity": 1, "texture": Resource}
var items = {}

signal inventory_updated

func add_item(item_name: String, texture: Texture2D, amount: int = 1):
	if items.has(item_name):
		items[item_name]["quantity"] += amount
	else:
		items[item_name] = {"quantity": amount, "texture": texture}
	
	inventory_updated.emit()

func remove_item(item_name: String, amount: int = 1):
	if items.has(item_name):
		items[item_name]["quantity"] -= amount
		if items[item_name]["quantity"] <= 0:
			items.erase(item_name)
		inventory_updated.emit()