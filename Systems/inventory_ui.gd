extends Control

@onready var grid = $GridContainer # Certifique-se que o nome está igual

func _ready() -> void:
	visible = false
	if InventoryManager:
		InventoryManager.inventory_updated.connect(update_ui)
	update_ui()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("abrir_inventario"):
		visible = !visible

func update_ui() -> void:
	# Limpa tudo para redesenhar
	for child in grid.get_children():
		child.queue_free()
	
	# 1. Criar os slots preenchidos
	for slot_data in InventoryManager.inventory:
		criar_slot_visual(slot_data)
	
	# 2. Criar slots vazios até completar 10
	var slots_vazios = InventoryManager.MAX_SLOTS - InventoryManager.inventory.size()
	for i in range(slots_vazios):
		criar_slot_visual(null)

func criar_slot_visual(data):
	# 1. Criar o Painel do Slot
	var slot_panel = Panel.new()
	slot_panel.custom_minimum_size = Vector2(64, 64)
	
	# Estilo do quadradinho
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.15, 0.15, 0.8)
	style.set_border_width_all(2)
	style.border_color = Color(0.4, 0.4, 0.4)
	style.set_corner_radius_all(4)
	slot_panel.add_theme_stylebox_override("panel", style)
	
	grid.add_child(slot_panel)
	
	if data != null:
		# 2. ÍCONE (Centralizado e com margem)
		var icon = TextureRect.new()
		icon.texture = data["texture"]
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		# Deixa uma margem de 5 pixels para não encostar na borda
		icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 5)
		slot_panel.add_child(icon)
		
		# 3. QUANTIDADE (No canto inferior direito, dentro do quadrado)
		var label = Label.new()
		label.text = str(data["amount"])
		# Diminuir um pouco a fonte se necessário
		label.add_theme_font_size_override("font_size", 14) 
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		# Fixa o texto no canto inferior direito do PAINEL
		label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT, Control.PRESET_MODE_MINSIZE, 2)
		# Contorno preto para facilitar a leitura
		label.add_theme_constant_override("outline_size", 3)
		label.add_theme_color_override("font_outline_color", Color.BLACK)
		slot_panel.add_child(label)
		
		# 4. NOME (Opcional: aparece ao passar o mouse)
		slot_panel.tooltip_text = data["name"]
		
func _on_slot_gui_input(event, item_name):
	# Aqui você pode detectar cliques para usar o item ou começar o arrasto
	if event is InputEventMouseButton and event.pressed:
		print("Clicou no item: ", item_name)