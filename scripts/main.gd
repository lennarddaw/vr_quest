extends Node3D
## Main VR Tutorial Scene Controller
##
## This script manages the overall VR tutorial scene, including
## initialization, spawning interactable objects, and coordinating
## between different systems.

# References to scene nodes
@onready var player_xr: XROrigin3D = $PlayerXR
@onready var game_manager: Node = $GameManager
@onready var interactables_container: Node3D = $Interactables
@onready var audio_manager: Node3D = $Audio

# Preloaded scenes
var cube_scene = preload("res://scenes/Cube.tscn")
var floating_label_scene = preload("res://scenes/FloatingLabel.tscn")

# Tutorial configuration
var cube_spawn_positions: Array[Vector3] = [
	Vector3(2, 1, -2),    # Blue cube
	Vector3(-2, 1, 2),    # Red cube  
	Vector3(3, 1.5, 1),   # Green cube
	Vector3(-1, 1, -3),   # Yellow cube
]

var cube_colors: Array[Color] = [
	Color.BLUE,
	Color.RED,
	Color.GREEN,
	Color.YELLOW
]

var cube_names: Array[String] = [
	"blue",
	"red", 
	"green",
	"yellow"
]

# Tutorial state
var cubes_spawned: Array[Node3D] = []
var current_instruction_label: Node3D = null

func _ready():
	print("🎮 VR Tutorial starting...")
	
	# Initialize XR
	initialize_xr()
	
	# Wait a frame for everything to be ready
	await get_tree().process_frame
	
	# Start the tutorial
	start_tutorial()

func initialize_xr():
	"""Initialize the XR interface"""
	var xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.is_initialized():
		print("✅ OpenXR initialized successfully")
		get_viewport().use_xr = true
	else:
		print("❌ OpenXR failed to initialize")
		print("🖥️ Running in desktop mode for testing")

func start_tutorial():
	"""Start the VR tutorial sequence"""
	print("🚀 Starting tutorial sequence...")
	
	# Spawn all cubes
	spawn_cubes()
	
	# Show first instruction
	show_instruction("Welcome to VR! Point at the BLUE cube and press trigger!", Vector3(0, 2.5, 0))
	
	# Connect to game manager signals
	if game_manager:
		game_manager.cube_collected.connect(_on_cube_collected)
		game_manager.tutorial_completed.connect(_on_tutorial_completed)

func spawn_cubes():
	"""Spawn all interactive cubes in the scene"""
	print("📦 Spawning cubes...")
	
	for i in range(cube_spawn_positions.size()):
		var cube_instance = cube_scene.instantiate()
		cube_instance.position = cube_spawn_positions[i]
		
		# Set cube properties
		cube_instance.setup_cube(cube_colors[i], cube_names[i], i)
		
		# Add to scene
		interactables_container.add_child(cube_instance)
		cubes_spawned.append(cube_instance)
		
		print("  ✅ Spawned ", cube_names[i], " cube at ", cube_spawn_positions[i])

func show_instruction(text: String, position: Vector3):
	"""Show a floating instruction label"""
	# Remove previous instruction
	if current_instruction_label:
		current_instruction_label.queue_free()
	
	# Create new instruction
	current_instruction_label = floating_label_scene.instantiate()
	current_instruction_label.position = position
	current_instruction_label.setup_label(text)
	
	add_child(current_instruction_label)
	print("💬 Showing instruction: ", text)

func _on_cube_collected(cube_color: String, cube_id: int):
	"""Handle when a cube is collected"""
	print("🎯 Cube collected: ", cube_color)
	
	# Show appropriate next instruction
	match cube_color:
		"blue":
			show_instruction("Great! Now find the RED cube!", Vector3(0, 2.5, 0))
		"red":
			show_instruction("Excellent! Point at the GREEN cube next!", Vector3(0, 2.5, 0))
		"green":
			show_instruction("Amazing! One more - find the YELLOW cube!", Vector3(0, 2.5, 0))
		"yellow":
			show_instruction("Perfect! You completed the tutorial!", Vector3(0, 2.5, 0))

func _on_tutorial_completed():
	"""Handle tutorial completion"""
	print("🎉 Tutorial completed successfully!")
	
	# Show completion message
	show_instruction("🎉 Congratulations! Tutorial Complete!\nYou've learned VR basics!", Vector3(0, 2.5, 0))
	
	# Optional: Add celebration effects, sounds, etc.
	play_completion_effects()

func play_completion_effects():
	"""Play celebration effects when tutorial is completed"""
	# TODO: Add particle effects, sounds, haptic feedback
	print("🎊 Playing celebration effects...")

func _input(event):
	"""Handle keyboard input for desktop testing"""
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ESCAPE:
				print("👋 Exiting tutorial...")
				get_tree().quit()
			KEY_R:
				print("🔄 Restarting tutorial...")
				get_tree().reload_current_scene()
			KEY_H:
				print("ℹ️ Help: ESC=Quit, R=Restart, H=Help")

func _on_tree_exiting():
	"""Cleanup when scene is exiting"""
	print("🧹 Cleaning up tutorial scene...")
	
	# Cleanup XR
	if get_viewport().use_xr:
		get_viewport().use_xr = false
