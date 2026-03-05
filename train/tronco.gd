extends Sprite2D

var agarrado = false
@onready var pos_inicial = position

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and get_rect().has_point(to_local(event.position)):
			agarrado = true
		elif agarrado:
			agarrado = false
			verificar_soltado()

func _process(_delta):
	if agarrado:
		global_position = get_global_mouse_position()

func verificar_soltado():
	# Checar si estamos sobre la caldera (usando grupos o distancias)
	var caldera = get_tree().get_first_node_in_group("caldera")
	if global_position.distance_to(caldera.global_position) < 50:
		get_node("/root/EscenaPrincipal").alimentar_caldera(10.0)
		position = pos_inicial # El tronco vuelve a su caja
	else:
		# Si lo sueltas fuera, regresa a su lugar
		var tween = create_tween()
		tween.tween_property(self, "position", pos_inicial, 0.2)
