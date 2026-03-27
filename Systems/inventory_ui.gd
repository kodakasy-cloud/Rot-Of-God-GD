extends Control

@onready var grid = $GridContainer

# Variável para rastrear qual item está sendo arrastado no momento
var dragging_item_data = null

func _ready() -> void:
	visible = false
	if InventoryManager:
		# Conecta o sinal para atualizar a grade automaticamente
		if InventoryManager.has_signal("inventory_updated"):
			InventoryManager.inventory_updated.connect(update_ui)
	update_ui()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("abrir_inventario"):
		visible = !visible
		if visible:
			update_ui()

func update_ui() -> void:
	if not grid: return
	
	# Limpa a grade antes de redesenhar
	for child in grid.get_children():
		child.queue_free()
	
	# 1. Cria os slots com itens existentes
	for slot_data in InventoryManager.inventory:
		criar_slot_visual(slot_data)
	
	# 2. Preenche o restante com slots vazios até o limite (10)
	var slots_vazios = InventoryManager.MAX_SLOTS - InventoryManager.inventory.size()
	for i in range(slots_vazios):
		criar_slot_visual(null)

func criar_slot_visual(data):
	var slot_panel = PanelContainer.new()
	slot_panel.custom_minimum_size = Vector2(90, 110)
	
	# Estilo visual do Slot
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.12, 0.12, 0.9)
	style.set_border_width_all(2)
	style.border_color = Color(0.4, 0.4, 0.4)
	style.set_corner_radius_all(6)
	slot_panel.add_theme_stylebox_override("panel", style)
	
	grid.add_child(slot_panel)
	
	if data != null:
		# Container para organizar os elementos verticalmente
		var vbox = VBoxContainer.new()
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE # Deixa o clique passar para o painel
		slot_panel.add_child(vbox)
		
		# Nome do Item
		var name_label = Label.new()
		name_label.text = data["name"]
		name_label.add_theme_font_size_override("font_size", 12)
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(name_label)
		
		# Ícone do Item
		var icon = TextureRect.new()
		icon.texture = data["texture"]
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.custom_minimum_size = Vector2(50, 50)
		vbox.add_child(icon)
		
		# Quantidade
		var qty_label = Label.new()
		qty_label.text = "x" + str(data["amount"])
		qty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(qty_label)
		
		# Habilita o comportamento de arrasto no painel
		slot_panel.set_script(slot_behavior_script)
		slot_panel.item_data = data
		slot_panel.parent_ui = self

# --- SCRIPT DE COMPORTAMENTO DO SLOT (INNER SCRIPT) ---
var slot_behavior_script = GDScript.new()

func _prepare_behavior():
	slot_behavior_script.source_code = """
extends PanelContainer

var item_data = null
var parent_ui = null

func _get_drag_data(_at_position):
	if item_data == null: return null
	
	# Salva o dado no pai para caso o drop falhe
	parent_ui.dragging_item_data = item_data
	
	# Cria o visual que segue o mouse
	var preview = TextureRect.new()
	preview.texture = item_data['texture']
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.custom_minimum_size = Vector2(50, 50)
	
	# Centraliza o preview no mouse
	var c = Control.new()
	c.add_child(preview)
	preview.position = -Vector2(25, 25)
	
	set_drag_preview(c)
	
	# Retorna o dicionário completo para o Mapa
	return item_data
"""
	slot_behavior_script.reload()

# Inicializa o script interno
func _init():
	_prepare_behavior()

# Detecta quando o arrasto terminou
func _notification(what):
	if what == NOTIFICATION_DRAG_END:
		# Se o drop NÃO foi capturado por outra UI, solta no chão
		if not get_viewport().gui_is_drag_successful():
			if dragging_item_data != null:
				forçar_drop_no_chao(dragging_item_data)
				dragging_item_data = null

func forçar_drop_no_chao(data):
	var mapa = get_tree().current_scene
	# Verifica se o script do mapa tem a função _drop_data que criamos
	if mapa.has_method("_drop_data"):
		mapa._drop_data(get_global_mouse_position(), data)