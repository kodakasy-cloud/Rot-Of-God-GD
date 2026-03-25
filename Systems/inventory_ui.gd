extends Control # Alterado para aceitar set_drag_preview

@onready var list: ItemList = $ItemList 

func _ready() -> void:
	visible = false
	if InventoryManager:
		InventoryManager.inventory_updated.connect(update_ui)
		update_ui()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("abrir_inventario"):
		visible = !visible

func update_ui() -> void:
	if list == null: return
	list.clear()
	
	for item_name in InventoryManager.items:
		var data = InventoryManager.items[item_name]
		var display_text = item_name + "\n(x" + str(data["quantity"]) + ")"
		var idx = list.add_item(display_text, data["texture"])
		list.set_item_metadata(idx, item_name)

# Esta função é chamada automaticamente pelo ItemList se ele for filho de um Control
func _get_drag_data(_at_position: Vector2):
	var selected = list.get_selected_items()
	
	if selected.size() > 0:
		var index = selected[0]
		var item_name = list.get_item_metadata(index)
		var item_texture = list.get_item_icon(index)
		
		var preview = TextureRect.new()
		preview.texture = item_texture
		preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		preview.custom_minimum_size = Vector2(50, 50)
		
		set_drag_preview(preview) # Agora o script reconhece porque 'extends Control'
		return item_name
	
	return null
# No inventory_ui.gd
func _notification(what):
	if what == NOTIFICATION_DRAG_END:
		if not get_viewport().gui_is_drag_successful():
			# Se o drop falhou (soltou fora de um receptor de UI), 
			# nós forçamos o drop no chão manualmente.
			forçar_drop_no_chao()

func forçar_drop_no_chao():
	var selected = list.get_selected_items()
	if selected.size() > 0:
		var item_name = list.get_item_metadata(selected[0])
		
		# Pede ao Mapa para criar o item
		var mapa = get_tree().current_scene
		if mapa.has_method("_drop_data"):
			mapa._drop_data(get_global_mouse_position(), item_name)
