extends Node3D

# --- Variables de Economía y Estado ---
var dinero: int = 200:
	set(nuevo_valor):
		dinero = nuevo_valor
		actualizar_ui()

var temperatura: float = 40.0 # Empezamos en nivel Moderado
var velocidad_base: float = 0.0
var multiplicador_freno: float = 1.0 # 1.0 = Libre, 0.0 = Frenado total
var juego_terminado: bool = false

# --- Configuración del Tiempo (8 min = 480 seg) ---
var tiempo_restante: float = 480.0 

# --- Referencias a Nodos ---
@onready var vias_mesh: MeshInstance3D = $Mundo3D/Vias_Infinitas
@onready var label_dinero: Label = $CanvasLayer/CalderaUI/DisplayDinero
@onready var label_reloj: Label = $CanvasLayer/CalderaUI/Reloj
@onready var sprite_cara: Sprite2D = $CanvasLayer/CalderaUI/CaraCaldera

var vias_material: ShaderMaterial

func _ready() -> void:
	if vias_mesh:
		vias_material = vias_mesh.get_active_material(0) as ShaderMaterial
	actualizar_ui()

func _process(delta: float) -> void:
	if juego_terminado: return
	
	procesar_tiempo(delta)
	procesar_caldera(delta)
	aplicar_movimiento_mundo()

func procesar_tiempo(delta: float) -> void:
	tiempo_restante -= delta
	if tiempo_restante <= 0:
		finalizar_dia()
	
	# Cálculo de hora (de 8:00 AM a 4:00 PM)
	var progreso_dia = 1.0 - (tiempo_restante / 480.0)
	var hora = int(8 + (progreso_dia * 8))
	label_reloj.text = str(hora) + ":00"

func procesar_caldera(delta: float) -> void:
	temperatura = clampf(temperatura - (2.5 * delta), 0.0, 100.0)
	
	# LÓGICA DE NIVELES Y SPRITESHEET
	if temperatura <= 30:
		velocidad_base = 0.5   
		sprite_cara.frame = 0  # Primera cara de la tira
	elif temperatura <= 70:
		velocidad_base = 1.5   
		sprite_cara.frame = 1  # Segunda cara
	elif temperatura <= 90:
		velocidad_base = 3.5   
		sprite_cara.frame = 2  # Tercera cara
	else:
		velocidad_base = 6.0   
		sprite_cara.frame = 3  # Cuarta cara (Dantesca)
		
		shake_camera(0.2)
		if temperatura >= 100:
			explotar_tren()
			
func aplicar_movimiento_mundo() -> void:
	if vias_material:
		# La velocidad final es la base del calor modificada por el freno
		var velocidad_final = velocidad_base * multiplicador_freno
		vias_material.set_shader_parameter("velocidad", velocidad_final)

# --- Funciones de Interacción ---

func alimentar_caldera(valor: float) -> void:
	if not juego_terminado:
		temperatura = clampf(temperatura + valor, 0.0, 100.0)

# Esta función la debe conectar tu Slider de freno (Range 0.0 a 1.0)
func _on_freno_slider_value_changed(value: float) -> void:
	# Si el slider es de 0 a 100, divide por 100. 
	# Invertimos si es necesario: 1.0 es velocidad normal, 0.0 es parado.
	multiplicador_freno = value 

func actualizar_ui() -> void:
	if label_dinero:
		label_dinero.text = "Felicidad: $" + str(dinero)

func shake_camera(intensity: float):
	var cam = get_viewport().get_camera_3d()
	if cam:
		cam.h_offset = randf_range(-intensity, intensity)
		cam.v_offset = randf_range(-intensity, intensity)

func explotar_tren():
	juego_terminado = true
	print("GAME OVER: El exceso de felicidad hizo explotar la caldera.")
	# Aquí disparas tu animación de explosión infantil

func finalizar_dia():
	juego_terminado = true
	print("Día terminado. Has sobrevivido a la vía.")
