extends Node3D

# -----------------------------------------
# Variables de configuración
# -----------------------------------------
@export var powerup_type: int = 0

@onready var area: Area3D = %Area3D
@onready var mesh: MeshInstance3D = %MeshInstance3D
@onready var pickup_sfx: AudioStreamPlayer3D = %PickupSFX

# -----------------------------------------
# Colores de powerups
# -----------------------------------------
var powerup_colors := [
	Color(0.2, 0.6, 1.0),    
	Color(1.0, 0.9, 0.2),    
	Color(1.0, 0.3, 0.3),    
	Color(0.6, 1.0, 0.3)     
]

var current_color_index := 0
var color_change_timer := 0.0
const COLOR_CHANGE_SPEED := 0.15    # Cambio cada 0.15 segundos

# -----------------------------------------
# Ready
# -----------------------------------------
func _ready():
	# Crear material base
	var m := StandardMaterial3D.new()
	m.albedo_color = powerup_colors[0]
	mesh.material_override = m
	
	pickup_sfx.stream = preload("res://scenes/heart_pickup/newlife.wav")

# -----------------------------------------
# Process: cambio de color cíclico
# -----------------------------------------
func _process(delta):
	color_change_timer += delta
	
	if color_change_timer >= COLOR_CHANGE_SPEED:
		color_change_timer = 0.0
		current_color_index = (current_color_index + 1) % powerup_colors.size()
		
		# Actualizar color del mesh
		if mesh.material_override:
			mesh.material_override.albedo_color = powerup_colors[current_color_index]

# -----------------------------------------
# Detección de recogida
# -----------------------------------------
func _on_area_3d_body_entered(body):
	if body != Player:
		return
	
	# Aplicar efecto según tipo
	var msg := ""
	
	if powerup_type == 0:
		Player.apply_knockback_resistance(8.0, 0.5)
		msg = "🛡️ Reducción de empuje"
	elif powerup_type == 1:
		Player.apply_fire_rate(8.0, 1.6)
		msg = "🔥 Aumento de cadencia"
	elif powerup_type == 2:
		Player.add_push_shield(1)
		msg = "⭐ Escudo anti-empuje"
	else:
		Player.enable_double_jump(10.0)
		msg = "🚀 Doble salto activado"
	
	# Notificación del powerup
	Player.show_powerup_toast(msg)
	print("Powerup: " + msg)
	
	# Sonido de recogida
	if pickup_sfx:
		pickup_sfx.play()
	
	await get_tree().create_timer(0.3).timeout
	queue_free()
