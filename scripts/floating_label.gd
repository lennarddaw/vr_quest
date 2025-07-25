extends Node3D
class_name FloatingLabel
## Floating 3D Label for VR Instructions
##
## Displays text instructions that float in 3D space and always face the player.
## Includes animations and customizable appearance.

# Label components
@onready var label_3d: Label3D = $Label3D
@onready var background_mesh: MeshInstance3D = $BackgroundMesh

# Label properties
var label_text: String = ""
var label_color: Color = Color.WHITE
var background_color: Color = Color(0, 0, 0, 0.7)
var font_size: int = 24

# Animation properties
var float_speed: float = 1.0
var float_height: float = 0.2
var fade_in_duration: float = 0.5
var fade_out_duration: float = 0.3
var auto_hide_duration: float = 0.0  # 0 = never auto hide

# State
var original_position: Vector3
var time_offset: float = 0.0
var is_visible: bool = true
var player_camera: Camera3D = null

# Signals
signal label_clicked()
signal label_fade_complete()

func _ready():
	print("💬 Setting up floating label...")
	
	# Store original position for floating animation
	original_position = position
	time_offset = randf() * TAU
	
	# Find player camera for billboard effect
	find_player_camera()
	
	# Setup initial appearance
	setup_appearance()
	
	# Start with fade-in animation
	start_fade_in_animation()
	
	# Setup auto-hide timer if specified
	if auto_hide_duration > 0:
		setup_auto_hide()

func setup_label(text: String, color: Color = Color.WHITE, size: int = 24):
	"""Configure the label with specific text and appearance"""
	label_text = text
	label_color = color
	font_size = size
	
	# Apply to Label3D if available
	if label_3d:
		label_3d.text = label_text
		label_3d.modulate = label_color
		# Note: font_size would need custom font resource in Godot 4
	
	print("📝 Label setup: '", text, "'")

func setup_appearance():
	"""Configure the visual appearance of the label"""
	if label_3d:
		label_3d.text = label_text
		label_3d.modulate = label_color
		label_3d.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label_3d.double_sided = false
		label_3d.shaded = false
		label_3d.alpha_cut = false
		label_3d.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	
	# Setup background if available
	if background_mesh:
		var material = StandardMaterial3D.new()
		material.albedo_color = background_color
		material.flags_transparent = true
		material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
		background_mesh.material_override = material

func find_player_camera():
	"""Find the XR camera in the scene"""
	# Look for XRCamera3D in the scene
	var xr_cameras = get_tree().get_nodes_in_group("xr_camera")
	if xr_cameras.size() > 0:
		player_camera = xr_cameras[0]
	else:
		# Fallback: find any Camera3D
		var cameras = get_tree().get_nodes_in_group("camera")
		if cameras.size() > 0:
			player_camera = cameras[0]
		else:
			# Last resort: search by type
			var found_camera = find_node_by_type(get_tree().root, "XRCamera3D")
			if not found_camera:
				found_camera = find_node_by_type(get_tree().root, "Camera3D")
			player_camera = found_camera

func find_node_by_type(node: Node, type_name: String) -> Node:
	"""Recursively find a node by its type name"""
	if node.get_class() == type_name:
		return node
	
	for child in node.get_children():
		var result = find_node_by_type(child, type_name)
		if result:
			return result
	
	return null

func _process(delta):
	"""Update label behavior every frame"""
	if is_visible:
		update_floating_animation(delta)
		update_billboard_rotation()

func update_floating_animation(delta):
	"""Create gentle floating motion"""
	var time = Time.get_time_dict_from_system().hour * 3600 + \
			   Time.get_time_dict_from_system().minute * 60 + \
			   Time.get_time_dict_from_system().second + \
			   Time.get_time_dict_from_system().millisecond / 1000.0
	
	var float_offset = sin((time + time_offset) * float_speed) * float_height
	position.y = original_position.y + float_offset

func update_billboard_rotation():
	"""Make label always face the player camera"""
	if player_camera:
		# Calculate direction to camera
		var camera_pos = player_camera.global_position
		var label_pos = global_position
		var direction = (camera_pos - label_pos).normalized()
		
		# Set rotation to face camera
		look_at(camera_pos, Vector3.UP)

func start_fade_in_animation():
	"""Animate label fading in"""
	if not label_3d:
		return
	
	# Start transparent
	var start_alpha = 0.0
	label_3d.modulate.a = start_alpha
	
	if background_mesh and background_mesh.material_override:
		background_mesh.material_override.albedo_color.a = 0.0
	
	# Create fade-in tween
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Fade in label
	tween.tween_property(label_3d, "modulate:a", 1.0, fade_in_duration)
	
	# Fade in background
	if background_mesh and background_mesh.material_override:
		tween.tween_property(background_mesh.material_override, "albedo_color:a", background_color.a, fade_in_duration)
	
	print("📈 Fading in label: '", label_text, "'")

func start_fade_out_animation():
	"""Animate label fading out"""
	if not label_3d:
		return
	
	is_visible = false
	
	# Create fade-out tween
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Fade out label
	tween.tween_property(label_3d, "modulate:a", 0.0, fade_out_duration)
	
	# Fade out background
	if background_mesh and background_mesh.material_override:
		tween.tween_property(background_mesh.material_override, "albedo_color:a", 0.0, fade_out_duration)
	
	# Remove after fade completes
	await tween.finished
	label_fade_complete.emit()
	queue_free()
	
	print("📉 Faded out label: '", label_text, "'")

func setup_auto_hide():
	"""Setup automatic hiding after specified duration"""
	var timer = Timer.new()
	timer.wait_time = auto_hide_duration
	timer.one_shot = true
	timer.timeout.connect(start_fade_out_animation)
	add_child(timer)
	timer.start()
	
	print("⏰ Auto-hide timer set for ", auto_hide_duration, " seconds")

func update_text(new_text: String):
	"""Update the label text dynamically"""
	label_text = new_text
	if label_3d:
		label_3d.text = label_text
	print("🔄 Updated label text: '", new_text, "'")

func update_color(new_color: Color):
	"""Update the label color dynamically"""
	label_color = new_color
	if label_3d:
		label_3d.modulate = Color(new_color.r, new_color.g, new_color.b, label_3d.modulate.a)
	print("🎨 Updated label color")

func hide_label():
	"""Manually hide the label"""
	start_fade_out_animation()

func show_label():
	"""Manually show the label"""
	is_visible = true
	start_fade_in_animation()

func set_auto_hide_duration(duration: float):
	"""Set auto-hide duration and restart timer"""
	auto_hide_duration = duration
	if duration > 0:
		setup_auto_hide()

# Input handling for interaction (desktop testing)
func _input_event(camera, event, click_pos, click_normal, shape_idx):
	"""Handle click events for desktop testing"""
	if event is InputEventMouseButton and event.pressed:
		print("🖱️ Label clicked: '", label_text, "'")
		label_clicked.emit()

# Utility functions
func get_distance_to_camera() -> float:
	"""Get distance from label to player camera"""
	if player_camera:
		return global_position.distance_to(player_camera.global_position)
	return 0.0

func is_in_camera_view() -> bool:
	"""Check if label is visible in camera view"""
	if not player_camera:
		return false
	
	# Simple check - could be improved with frustum culling
	var to_camera = player_camera.global_position - global_position
	var camera_forward = -player_camera.global_transform.basis.z
	
	return to_camera.dot(camera_forward) > 0

func pulse_animation(duration: float = 0.5, scale_factor: float = 1.2):
	"""Create a pulse animation to draw attention"""
	var original_scale = scale
	
	var tween = create_tween()
	tween.tween_property(self, "scale", original_scale * scale_factor, duration / 2)
	tween.tween_property(self, "scale", original_scale, duration / 2)
	
	print("💓 Pulsing label for attention")