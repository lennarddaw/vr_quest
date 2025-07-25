extends Node3D
class_name InteractableCube
## Interactive Cube for VR Tutorial
##
## A cube that can be pointed at and interacted with in VR.
## Changes appearance when pointed at and disappears when triggered.

# Cube properties
var cube_color: Color = Color.WHITE
var cube_name: String = "cube"
var cube_id: int = 0
var is_collected: bool = false

# Visual components
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var collision_shape: CollisionShape3D = $Area3D/CollisionShape3D
@onready var area_3d: Area3D = $Area3D
@onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D

# Materials
var normal_material: StandardMaterial3D
var highlight_material: StandardMaterial3D

# Animation
var is_highlighted: bool = false
var hover_animation_speed: float = 2.0
var hover_height: float = 0.1
var original_position: Vector3
var time_offset: float = 0.0

# Interaction settings
var can_be_interacted: bool = true
var interaction_distance: float = 10.0

# Signals
signal cube_interacted(cube_color: String, cube_id: int)
signal cube_pointed_at(cube: InteractableCube)
signal cube_point_lost(cube: InteractableCube)

func _ready():
	print("🧊 Setting up cube: ", name)
	
	# Store original position for hover animation
	original_position = position
	time_offset = randf() * TAU  # Random animation offset
	
	# Setup area for interaction
	setup_interaction_area()
	
	# Create materials
	create_materials()

func setup_cube(color: Color, cube_name_param: String, id: int):
	"""Initialize cube with specific properties"""
	cube_color = color
	cube_name = cube_name_param
	cube_id = id
	name = cube_name + "_cube"
	
	print("✅ Cube setup: ", cube_name, " (ID: ", id, ")")
	
	# Apply color to material
	if normal_material:
		normal_material.albedo_color = cube_color

func setup_interaction_area():
	"""Configure the Area3D for interactions"""
	if area_3d:
		area_3d.collision_layer = 2  # Interactables layer
		area_3d.collision_mask = 0
		area_3d.monitoring = true
		area_3d.monitorable = true
		
		# Connect area signals
		if not area_3d.mouse_entered.is_connected(_on_area_3d_mouse_entered):
			area_3d.mouse_entered.connect(_on_area_3d_mouse_entered)
		if not area_3d.mouse_exited.is_connected(_on_area_3d_mouse_exited):
			area_3d.mouse_exited.connect(_on_area_3d_mouse_exited)

func create_materials():
	"""Create normal and highlight materials for the cube"""
	# Normal material
	normal_material = StandardMaterial3D.new()
	normal_material.albedo_color = cube_color
	normal_material.metallic = 0.0
	normal_material.roughness = 0.8
	
	# Highlight material (brighter and emissive)
	highlight_material = StandardMaterial3D.new()
	highlight_material.albedo_color = cube_color * 1.2
	highlight_material.metallic = 0.2
	highlight_material.roughness = 0.6
	highlight_material.emission_enabled = true
	highlight_material.emission = cube_color * 0.3
	highlight_material.emission_energy = 0.5
	
	# Apply normal material initially
	if mesh_instance:
		mesh_instance.material_override = normal_material

func _process(delta):
	"""Update cube animations and behavior"""
	if not is_collected:
		update_hover_animation(delta)

func update_hover_animation(delta):
	"""Create a floating hover animation"""
	var time = Time.get_time_dict_from_system().hour * 3600 + \
			   Time.get_time_dict_from_system().minute * 60 + \
			   Time.get_time_dict_from_system().second + \
			   Time.get_time_dict_from_system().millisecond / 1000.0
	
	var hover_offset = sin((time + time_offset) * hover_animation_speed) * hover_height
	position.y = original_position.y + hover_offset
	
	# Add subtle rotation
	rotation.y += delta * 0.5

func can_interact() -> bool:
	"""Check if this cube can be interacted with"""
	return can_be_interacted and not is_collected

func on_pointed_at():
	"""Called when a controller points at this cube"""
	if not can_interact():
		return
	
	print("👉 Pointing at: ", cube_name, " cube")
	
	# Change to highlight material
	is_highlighted = true
	if mesh_instance and highlight_material:
		mesh_instance.material_override = highlight_material
	
	# Emit signal
	cube_pointed_at.emit(self)
	
	# Play hover sound
	play_audio("hover")

func on_point_lost():
	"""Called when controller stops pointing at this cube"""
	if not can_interact():
		return
	
	print("👈 Lost point on: ", cube_name, " cube")
	
	# Change back to normal material
	is_highlighted = false
	if mesh_instance and normal_material:
		mesh_instance.material_override = normal_material
	
	# Emit signal
	cube_point_lost.emit(self)

func interact():
	"""Called when player triggers interaction (e.g., trigger button)"""
	if not can_interact():
		return
	
	print("⚡ Interacting with: ", cube_name, " cube")
	
	# Mark as collected
	is_collected = true
	can_be_interacted = false
	
	# Play interaction sound
	play_audio("collect")
	
	# Emit interaction signal
	cube_interacted.emit(cube_name, cube_id)
	
	# Start collection animation
	start_collection_animation()

func start_collection_animation():
	"""Animate cube collection (shrink and fade)"""
	print("🎬 Starting collection animation for: ", cube_name)
	
	# Create a tween for smooth animation
	var tween = create_tween()
	tween.set_parallel(true)  # Allow multiple animations simultaneously
	
	# Scale down
	tween.tween_property(self, "scale", Vector3.ZERO, 0.5)
	
	# Move up slightly
	tween.tween_property(self, "position", position + Vector3(0, 1, 0), 0.5)
	
	# Rotate faster
	tween.tween_property(self, "rotation", rotation + Vector3(0, TAU * 2, 0), 0.5)
	
	# Wait for animation to complete, then remove cube
	await tween.finished
	
	print("🗑️ Removing collected cube: ", cube_name)
	queue_free()

func play_audio(audio_type: String):
	"""Play audio feedback for interactions"""
	if not audio_player:
		return
	
	# TODO: Load and play appropriate sound effects
	match audio_type:
		"hover":
			# Play subtle hover sound
			pass
		"collect":
			# Play collection sound
			pass
	
	# For now, just print
	print("🔊 Playing audio: ", audio_type, " for ", cube_name)

func _on_area_3d_mouse_entered():
	"""Handle mouse enter (for desktop testing)"""
	if can_interact():
		on_pointed_at()

func _on_area_3d_mouse_exited():
	"""Handle mouse exit (for desktop testing)"""
	if can_interact():
		on_point_lost()

func _input_event(camera, event, click_pos, click_normal, shape_idx):
	"""Handle input events for desktop testing"""
	if event is InputEventMouseButton and event.pressed:
		if can_interact():
			interact()

# Utility functions for external scripts
func get_cube_info() -> Dictionary:
	"""Return information about this cube"""
	return {
		"name": cube_name,
		"color": cube_color,
		"id": cube_id,
		"position": position,
		"is_collected": is_collected,
		"can_interact": can_interact()
	}

func reset_cube():
	"""Reset cube to initial state (useful for restarting tutorial)"""
	is_collected = false
	can_be_interacted = true
	is_highlighted = false
	position = original_position
	scale = Vector3.ONE
	
	if mesh_instance and normal_material:
		mesh_instance.material_override = normal_material
	
	print("🔄 Reset cube: ", cube_name)
