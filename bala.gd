extends Area2D

const SPEED = 800.0
# Define a distância máxima que a bala percorre (em pixels)
const MAX_RANGE = 300.0 

var direcao = Vector2.ZERO
# Variável para guardar onde a bala "nasceu"
var posicao_inicial = Vector2.ZERO

func _ready():
	# Assim que a bala entra na cena, salvamos a posição de partida
	posicao_inicial = global_position

func _physics_process(delta):
	if direcao != Vector2.ZERO:
		global_position += direcao * SPEED * delta
	
	# CALCULAR DISTÂNCIA PERCORRIDA
	# A função 'distance_to' compara a posição atual com a inicial
	var distancia_atual = global_position.distance_to(posicao_inicial)
	
	# Se a distância for maior que o nosso limite, a bala some
	if distancia_atual >= MAX_RANGE:
		destruir_bala()

func destruir_bala():
	# Criamos uma função separada caso você queira adicionar 
	# uma animação de faísca ou som antes dela sumir
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()