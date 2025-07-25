extends XROrigin3D
## VR Player Controller
##
## Handles VR camera, controller input, and interaction with objects
## Manages raycast interactions and haptic feedback

# Controller references
@onready var left_controller: XRController3D = $LeftController
@onready var right_controller: XRController3D = $RightController
@onready var left_raycast: RayCast3D = $LeftController/LeftRaycast
@onready var right_raycast: RayCast3D = $RightController/RightRaycast
@onready var left_ray_visual: MeshInstance3D = $LeftController/LeftRaycast/LeftRayVisual
@onready var right_ray_visual: MeshInstance3D = $RightController/RightRaycast/RightRayVisual
@onready var xr_camera: XRCamera3D = $XRCamera3D

# Interaction settings
var raycast_enabled: bool = true
var haptic_feedback_enabled: bool = true
var ray_visual_enabled: bool = true

# Current interaction state
var left_pointing_at: Node3D = null
var right_pointing_at: Node3D = null
var left_trigger_pressed: bool = false
var right_trigger_pressed: bool = false

# Signals for interaction events
signal object_pointed_at(object: Node3D, controller: String)
signal object_point_lost(object: Node3D, controller: String)
signal object_triggered(object: Node3D, controller: String)

func _ready():
	print("🎮 Initializing VR Player...")
	
	# Configure raycasts
	setup_raycasts()
	
	# Setup visual feedback
	setup_ray_visuals()
	
	print("✅ VR Player initialized")

func setup_raycasts():
	"""Configure raycast properties for interaction"""
	# Left raycast
	left_raycast.enabled = true
	left_raycast.collision_mask = 6  # Layers 2 (Interactables) and 3 (UI)
	left_raycast.collide_with_areas = true
	left_raycast.collide_with_bodies = true
	
	# Right raycast  
	right_raycast.enabled = true
	right_raycast.collision_mask = 6  # Layers 2 (Interactables) and 3 (UI)
	right_raycast.collide_with_areas = true
	right_raycast.collide_with_bodies = true
	
	print("🎯 Raycasts configured")

func setup_ray_visuals():
	"""Setup visual feedback for controller rays"""
	if ray_visual_enabled:
		left_ray_visual.visible = false
		right_ray_visual.visible = false
	else:
		left_ray_visual.visible = false
		right_ray_visual.visible = false

func _process(delta):
	"""Update VR interactions every frame"""
	if raycast_enabled:
		update_raycast_interactions()
	
	update_ray_visuals()

func update_raycast_interactions():
	"""Check for raycast hits and update interaction state"""
	# Left controller
	update_controller_interaction(left_raycast, "left")
	
	# Right controller
	update_controller_interaction(right_raycast, "right")

func update_controller_interaction(raycast: RayCast3D, controller_name: String):
	"""Update interaction for a specific controller"""
	var current_pointing: Node3D = null
	var previous_pointing: Node3D = null
	
	# Get current and previous targets
	if controller_name == "left":
		previous_pointing = left_pointing_at
	else:
		previous_pointing = right_pointing_at
	
	# Check for hit
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		
		# Check if it's an interactable object
		if collider and collider.has_method("can_interact"):
			if collider.can_interact():
				current_pointing = collider
	
	# Update pointing state
	if controller_name == "left":
		left_pointing_at = current_pointing
	else:
		right_pointing_at = current_pointing
	
	# Handle pointing events
	if current_pointing != previous_pointing:
		# Lost previous target
		if previous_pointing:
			object_point_lost.emit(previous_pointing, controller_name)
			if previous_pointing.has_method("on_point_lost"):
				previous_pointing.on_point_lost()
		
		# Found new target
		if current_pointing:
			object_pointed_at.emit(current_pointing, controller_name)
			if current_pointing.has_method("on_pointed_at"):
				current_pointing.on_pointed_at()
			
			# Haptic feedback when pointing at object
			trigger_haptic_feedback(controller_name, 0.3, 0.1)

func update_ray_visuals():
	"""Update visual feedback for controller rays"""
	if not ray_visual_enabled:
		return
	
	# Left ray visual
	if left_pointing_at or left_trigger_pressed:
		left_ray_visual.visible = true
		update_ray_length(left_raycast, left_ray_visual)
	else:
		left_ray_visual.visible = false
	
	# Right ray visual
	if right_pointing_at or right_trigger_pressed:
		right_ray_visual.visible = true
		update_ray_length(right_raycast, right_ray_visual)
	else:
		right_ray_visual.visible = false

func update_ray_length(raycast: RayCast3D, ray_visual: MeshInstance3D):
	"""Update the visual length of a controller ray"""
	var hit_distance = 10.0  # Default max distance
	
	if raycast.is_colliding():
		var hit_point = raycast.get_collision_point()
		var ray_origin = raycast.global_position
		hit_distance = ray_origin.distance_to(hit_point)
	
	# Update visual mesh scale
	ray_visual.position.z = -hit_distance / 2.0
	var mesh = ray_visual.mesh as CylinderMesh
	if mesh:
		mesh.height = hit_distance

func _on_left_controller_button_pressed(name: String):
	"""Handle left controller button press"""
	handle_button_press(name, "left")

func _on_left_controller_button_released(name: String):
	"""Handle left controller button release"""
	handle_button_release(name, "left")

func _on_right_controller_button_pressed(name: String):
	"""Handle right controller button press"""
	handle_button_press(name, "right")

func _on_right_controller_button_released(name: String):
	"""Handle right controller button release"""
	handle_button_release(name, "right")

func handle_button_press(button_name: String, controller: String):
	"""Handle controller button press events"""
	print("🔘 Button pressed: ", button_name, " on ", controller, " controller")
	
	match button_name:
		"trigger_click":
			if controller == "left":
				left_trigger_pressed = true
				handle_trigger_interaction(left_pointing_at, "left")
			else:
				right_trigger_pressed = true
				handle_trigger_interaction(right_pointing_at, "right")
		
		"grip_click":
			# Handle grip button (could be used for grabbing)
			print("👊 Grip pressed on ", controller)
		
		"primary_click":  # A/X button
			# Handle primary button
			print("🅰️ Primary button pressed on ", controller)

func handle_button_release(button_name: String, controller: String):
	"""Handle controller button release events"""
	match button_name:
		"trigger_click":
			if controller == "left":
				left_trigger_pressed = false
			else:
				right_trigger_pressed = false

func handle_trigger_interaction(target: Node3D, controller: String):
	"""Handle trigger interaction with pointed object"""
	if target:
		print("⚡ Triggering interaction with: ", target.name)
		
		# Emit interaction signal
		object_triggered.emit(target, controller)
		
		# Call object's interaction method
		if target.has_method("interact"):
			target.interact()
		
		# Strong haptic feedback on interaction
		trigger_haptic_feedback(controller, 0.8, 0.2)
	else:
		print("❌ No target to interact with")

func trigger_haptic_feedback(controller: String, strength: float, duration: float):
	"""Trigger haptic feedback on specified controller"""
	if not haptic_feedback_enabled:
		return
	
	var controller_node: XRController3D
	
	if controller == "left":
		controller_node = left_controller
	else:
		controller_node = right_controller
	
	if controller_node:
		# Trigger haptic pulse
		controller_node.trigger_haptic_pulse("haptic", 0, strength, duration, 0)

func set_raycast_enabled(enabled: bool):
	"""Enable/disable raycast interactions"""
	raycast_enabled = enabled
	left_raycast.enabled = enabled
	right_raycast.enabled = enabled

func set_ray_visuals_enabled(enabled: bool):
	"""Enable/disable visual ray feedback"""
	ray_visual_enabled = enabled
	if not enabled:
		left_ray_visual.visible = false
		right_ray_visual.visible = false

func get_camera_position() -> Vector3:
	"""Get the current VR camera position"""
	return xr_camera.global_position

func get_camera_forward() -> Vector3:
	"""Get the current VR camera forward direction"""
	return -xr_camera.global_transform.basis.z
