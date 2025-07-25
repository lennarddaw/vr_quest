extends Node
class_name GameManager
## Game Manager for VR Tutorial
##
## Manages tutorial progression, scoring, and overall game state.
## Tracks which cubes have been collected and guides the player through the experience.

# Tutorial state
enum TutorialState {
	STARTING,
	FIND_BLUE,
	FIND_RED,
	FIND_GREEN,
	FIND_YELLOW,
	COMPLETED
}

var current_state: TutorialState = TutorialState.STARTING
var collected_cubes: Array[String] = []
var total_cubes: int = 4
var tutorial_start_time: float = 0.0

# Tutorial progression
var cube_sequence: Array[String] = ["blue", "red", "green", "yellow"]
var current_target_index: int = 0

# Score and performance tracking
var score: int = 0
var time_bonuses: Array[float] = []
var interaction_count: int = 0

# Signals
signal cube_collected(cube_color: String, cube_id: int)
signal tutorial_completed()
signal state_changed(new_state: TutorialState)
signal score_updated(new_score: int)

func _ready():
	print("🎮 Game Manager initialized")
	tutorial_start_time = Time.get_time_dict_from_system().hour * 3600 + \
						 Time.get_time_dict_from_system().minute * 60 + \
						 Time.get_time_dict_from_system().second
	
	# Start tutorial
	start_tutorial()

func start_tutorial():
	"""Initialize and start the tutorial"""
	print("🚀 Starting VR tutorial...")
	
	# Reset state
	current_state = TutorialState.FIND_BLUE
	collected_cubes.clear()
	current_target_index = 0
	score = 0
	interaction_count = 0
	
	# Connect to cube signals
	connect_cube_signals()
	
	# Emit initial state
	state_changed.emit(current_state)
	score_updated.emit(score)

func connect_cube_signals():
	"""Connect to all cube interaction signals"""
	# Find all cubes in the scene and connect their signals
	var cubes = get_tree().get_nodes_in_group("interactable_cubes")
	
	for cube in cubes:
		if cube.has_signal("cube_interacted"):
			if not cube.cube_interacted.is_connected(_on_cube_interacted):
				cube.cube_interacted.connect(_on_cube_interacted)
				print("🔗 Connected to cube: ", cube.cube_name)

func _on_cube_interacted(cube_color: String, cube_id: int):
	"""Handle cube interaction events"""
	print("📦 Cube collected: ", cube_color, " (ID: ", cube_id, ")")
	
	interaction_count += 1
	
	# Check if this is the correct cube for current state
	if is_correct_cube(cube_color):
		handle_correct_cube(cube_color, cube_id)
	else:
		handle_incorrect_cube(cube_color)

func is_correct_cube(cube_color: String) -> bool:
	"""Check if the collected cube is the correct one for current tutorial step"""
	var expected_color = get_expected_cube_color()
	return cube_color == expected_color

func get_expected_cube_color() -> String:
	"""Get the color of the cube the player should collect next"""
	if current_target_index < cube_sequence.size():
		return cube_sequence[current_target_index]
	return ""

func handle_correct_cube(cube_color: String, cube_id: int):
	"""Handle collection of the correct cube"""
	print("✅ Correct cube collected: ", cube_color)
	
	# Add to collected cubes
	collected_cubes.append(cube_color)
	
	# Calculate score with time bonus
	var time_bonus = calculate_time_bonus()
	var cube_points = 100 + time_bonus
	score += cube_points
	
	print("🏆 Score: +", cube_points, " (Total: ", score, ")")
	
	# Emit signals
	cube_collected.emit(cube_color, cube_id)
	score_updated.emit(score)
	
	# Progress to next state
	advance_tutorial_state()

func handle_incorrect_cube(cube_color: String):
	"""Handle collection of an incorrect cube"""
	print("❌ Incorrect cube collected: ", cube_color)
	print("💡 Expected: ", get_expected_cube_color())
	
	# Small score penalty for wrong cube
	score = max(0, score - 10)
	score_updated.emit(score)
	
	# TODO: Show feedback to player about incorrect choice
	show_incorrect_feedback(cube_color)

func calculate_time_bonus() -> int:
	"""Calculate time bonus based on collection speed"""
	var current_time = Time.get_time_dict_from_system().hour * 3600 + \
					   Time.get_time_dict_from_system().minute * 60 + \
					   Time.get_time_dict_from_system().second
	
	var time_elapsed = current_time - tutorial_start_time
	
	# Bonus decreases over time (max 50 points for very fast collection)
	var time_bonus = max(0, 50 - int(time_elapsed * 2))
	time_bonuses.append(time_bonus)
	
	return time_bonus

func advance_tutorial_state():
	"""Move to the next tutorial state"""
	current_target_index += 1
	
	match current_target_index:
		1:
			current_state = TutorialState.FIND_RED
		2:
			current_state = TutorialState.FIND_GREEN
		3:
			current_state = TutorialState.FIND_YELLOW
		4:
			current_state = TutorialState.COMPLETED
			complete_tutorial()
			return
	
	print("📈 Tutorial state advanced to: ", TutorialState.keys()[current_state])
	state_changed.emit(current_state)

func complete_tutorial():
	"""Handle tutorial completion"""
	print("🎉 Tutorial completed!")
	
	current_state = TutorialState.COMPLETED
	
	# Calculate final score
	var completion_bonus = 200
	var perfect_bonus = 0
	
	if collected_cubes.size() == total_cubes and interaction_count == total_cubes:
		perfect_bonus = 100
		print("⭐ Perfect completion bonus: +", perfect_bonus)
	
	score += completion_bonus + perfect_bonus
	
	# Print final statistics
	print_final_stats()
	
	# Emit completion signals
	state_changed.emit(current_state)
	tutorial_completed.emit()
	score_updated.emit(score)

func print_final_stats():
	"""Print final tutorial statistics"""
	var total_time = Time.get_time_dict_from_system().hour * 3600 + \
					 Time.get_time_dict_from_system().minute * 60 + \
					 Time.get_time_dict_from_system().second - tutorial_start_time
	
	print("📊 TUTORIAL STATISTICS:")
	print("  📦 Cubes collected: ", collected_cubes.size(), "/", total_cubes)
	print("  ⏱️ Total time: ", total_time, " seconds")
	print("  🎯 Total interactions: ", interaction_count)
	print("  🏆 Final score: ", score)
	print("  ⚡ Average time per cube: ", total_time / collected_cubes.size() if collected_cubes.size() > 0 else 0)

func show_incorrect_feedback(cube_color: String):
	"""Show feedback when player collects wrong cube"""
	var expected = get_expected_cube_color()
	print("💬 Feedback: You collected ", cube_color, " but need to find ", expected, " first!")
	
	# TODO: Display visual feedback in VR
	# This could trigger a floating message or audio cue

func get_tutorial_progress() -> float:
	"""Get tutorial completion progress (0.0 to 1.0)"""
	return float(collected_cubes.size()) / float(total_cubes)

func get_current_objective() -> String:
	"""Get the current tutorial objective as a string"""
	match current_state:
		TutorialState.STARTING:
			return "Welcome to VR! Get ready to start."
		TutorialState.FIND_BLUE:
			return "Find and collect the BLUE cube"
		TutorialState.FIND_RED:
			return "Find and collect the RED cube"
		TutorialState.FIND_GREEN:
			return "Find and collect the GREEN cube"
		TutorialState.FIND_YELLOW:
			return "Find and collect the YELLOW cube"
		TutorialState.COMPLETED:
			return "Tutorial completed! Great job!"
		_:
			return "Unknown objective"

func restart_tutorial():
	"""Restart the tutorial from the beginning"""
	print("🔄 Restarting tutorial...")
	
	# Reset all tracking variables
	current_state = TutorialState.STARTING
	collected_cubes.clear()
	current_target_index = 0
	score = 0
	interaction_count = 0
	time_bonuses.clear()
	
	# Reset start time
	tutorial_start_time = Time.get_time_dict_from_system().hour * 3600 + \
						 Time.get_time_dict_from_system().minute * 60 + \
						 Time.get_time_dict_from_system().second
	
	# Start again
	start_tutorial()

func _input(event):
	"""Handle debug input for testing"""
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F1:
				print("🔍 DEBUG: Current state = ", TutorialState.keys()[current_state])
				print("🔍 DEBUG: Expected cube = ", get_expected_cube_color())
				print("🔍 DEBUG: Progress = ", get_tutorial_progress() * 100, "%")
			KEY_F2:
				print("🔍 DEBUG: Collected cubes = ", collected_cubes)
				print("🔍 DEBUG: Score = ", score)
				print("🔍 DEBUG: Interactions = ", interaction_count)

# Utility functions for external access
func is_tutorial_active() -> bool:
	"""Check if tutorial is currently active"""
	return current_state != TutorialState.COMPLETED

func get_remaining_cubes() -> Array[String]:
	"""Get list of cubes that still need to be collected"""
	var remaining: Array[String] = []
	
	for cube_color in cube_sequence:
		if cube_color not in collected_cubes:
			remaining.append(cube_color)
	
	return remaining
