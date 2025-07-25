# VR Tutorial Quest - Educational VR Project

A simple, educational VR application for Meta Quest 3 built with Godot Engine 4.2+. Designed to teach students VR development fundamentals through interactive cube collection gameplay.

## Educational Goals

- **VR Development Basics**: Learn Godot VR setup and scene structure
- **3D Interaction Design**: Understand raycast interactions and object manipulation  
- **Game Logic Programming**: Implement state management and progression systems
- **Cross-Platform Deployment**: Deploy to Meta Quest hardware
- **STEM Integration**: Bridge technology concepts with hands-on learning

## Technical Stack

| Component | Technology |
|-----------|------------|
| **Engine** | Godot Engine 4.2+ |
| **VR Platform** | Meta Quest 3 (OpenXR) |
| **Language** | GDScript |
| **Rendering** | Vulkan/OpenGL ES |
| **Build Target** | Android APK |

## 📁 Project Structure

```
vr_tutorial_quest/
├── 📄 project.godot           # Main project configuration
├── 📄 export_presets.cfg      # Quest deployment settings
├── 📄 README.md               # This file
│
├── 📁 scenes/                 # 3D scenes and UI
│   ├── Main.tscn             # Primary VR environment
│   ├── PlayerXR.tscn         # VR camera & controllers
│   ├── Cube.tscn             # Interactive objects
│   ├── FloatingLabel.tscn    # 3D instruction text
│   └── GameManager.tscn      # Tutorial logic
│
├── 📁 scripts/               # Game logic (GDScript)
│   ├── main.gd              # Scene coordination
│   ├── player_xr.gd         # VR input handling
│   ├── cube.gd              # Object interaction
│   ├── floating_label.gd    # UI text behavior
│   ├── game_manager.gd      # Tutorial progression
│   └── xr_interactable.gd   # Base interaction class
│
├── 📁 xr/                    # VR configuration
│   ├── openxr_config.tres   # OpenXR settings
│   └── xr_action_map.tres   # Controller mappings
│
├── 📁 materials/             # 3D materials & textures
├── 📁 audio/                 # Sound effects
├── 📁 documentation/         # Guides & tutorials
└── 📁 builds/                # Compiled APK files
```

## Quick Start

### Prerequisites
1. **Godot Engine 4.2+** - [Download](https://godotengine.org/)
2. **Android SDK** - [Setup Guide](https://docs.godotengine.org/en/stable/getting_started/workflow/export/exporting_for_android.html)
3. **Meta Quest 3** with Developer Mode enabled
4. **USB-C cable** for device connection

### Installation Steps

1. **Clone/Download Project**
   ```bash
   git clone <repository-url>
   cd vr_tutorial_quest
   ```

2. **Open in Godot**
   - Launch Godot Engine
   - Click "Import" → Select `project.godot`
   - Wait for project import to complete

3. **Configure VR Settings**
   - Go to `Project → Project Settings → XR`
   - Enable **OpenXR** 
   - Set **Default Action Map** to `res://xr/xr_action_map.tres`

4. **Setup Android Export**
   - `Project → Export → Add → Android`
   - Configure Android SDK path
   - Set keystore for signing (or use debug)

5. **Connect Quest Device**
   - Enable Developer Mode on Quest 3
   - Connect via USB-C cable
   - Accept debugging permissions

6. **Build & Deploy**
   - Select Android export preset
   - Click **Export Project** or **Deploy to Device**
   - Install APK on Quest 3

## 🎮 Gameplay Overview

### Tutorial Flow
1. **Welcome** - Player spawns in VR room with floating instructions
2. **Blue Cube** - "Point at the BLUE cube and press trigger!"
3. **Red Cube** - "Great! Now find the RED cube!"
4. **Green Cube** - "Excellent! Point at the GREEN cube next!"
5. **Yellow Cube** - "Amazing! One more - find the YELLOW cube!"
6. **Completion** - "Perfect! You completed the tutorial!"

### Interaction System
- **Point**: Aim controller ray at objects (visual feedback)
- **Trigger**: Press trigger button to interact with highlighted objects
- **Haptic Feedback**: Controller vibration on interactions
- **Visual Cues**: Objects glow when pointed at
- **Audio Feedback**: Success sounds and ambient audio

## Educational Extensions

### Beginner Activities
- **Color Recognition**: Identify and collect cubes by color
- **Spatial Awareness**: Navigate 3D environment safely
- **Hand-Eye Coordination**: Precise pointing and clicking

### Intermediate Projects
- **Custom Objects**: Add new shapes (spheres, pyramids, complex models)
- **Sound Design**: Implement audio feedback and background music
- **Animation Systems**: Create object animations and particle effects

### Advanced Challenges
- **Scoring System**: Implement time-based scoring and leaderboards
- **Multiple Levels**: Design progressive difficulty environments
- **Physics Integration**: Add gravity, collisions, and object physics
- **Multiplayer Features**: Shared VR experiences and collaboration

## Development Guide

### Key Scripts Overview

**main.gd** - Scene coordination and tutorial initialization
```gdscript
# Core functions:
- initialize_xr()        # Setup VR interface
- spawn_cubes()         # Create interactive objects  
- show_instruction()    # Display 3D text prompts
```

**player_xr.gd** - VR controller and interaction handling
```gdscript
# Key features:
- Raycast interaction detection
- Haptic feedback on actions
- Visual ray rendering
- Multi-controller support
```

**cube.gd** - Interactive object behavior
```gdscript
# Interaction system:
- can_interact()        # Check interaction availability
- on_pointed_at()       # Highlight when targeted
- interact()            # Handle trigger events
```

**game_manager.gd** - Tutorial progression and scoring
```gdscript
# State management:
- Tutorial phases tracking
- Score calculation with time bonuses
- Progress monitoring
```

### Adding New Features

1. **New Interactive Objects**
   - Extend `xr_interactable.gd` base class
   - Implement `can_interact()` and `interact()` methods
   - Add to Interactables layer (collision_layer = 2)

2. **Custom Animations**
   - Use Godot's Tween system for smooth transitions
   - Implement in `_process()` for continuous effects
   - Combine position, rotation, and scale changes

3. **Audio Integration**
   - Add AudioStreamPlayer3D nodes for spatial audio
   - Load .ogg files for Quest compatibility
   - Trigger sounds via script events

## Learning Resources

### Godot VR Development
- [Official Godot XR Documentation](https://docs.godotengine.org/en/stable/tutorials/xr/index.html)
- [OpenXR Action System Guide](https://docs.godotengine.org/en/stable/tutorials/xr/openxr_action_map.html)
- [VR Best Practices](https://docs.godotengine.org/en/stable/tutorials/xr/vr_starter_tutorial.html)

### Meta Quest Development
- [Quest Developer Center](https://developer.oculus.com/)
- [Quest 3 Technical Specifications](https://developer.oculus.com/documentation/)
- [Android Development for Quest](https://developer.android.com/guide)

### Educational Integration
- Computer Science curriculum alignment
- STEAM project ideas and extensions
- Assessment rubrics for VR projects

## Troubleshooting

### Common Issues

**"OpenXR failed to initialize"**
- Ensure Quest 3 is connected and in Developer Mode
- Check USB-C cable connection
- Restart Godot and reconnect device

**"Export template not found"**
- Download Android export templates in Godot
- `Editor → Manage Export Templates → Download and Install`

**"APK installation failed"**
- Enable "Install from Unknown Sources" on Quest
- Check Android SDK configuration
- Verify keystore signing settings

**Performance Issues**
- Reduce render resolution in project settings
- Optimize mesh complexity and texture sizes
- Disable unnecessary post-processing effects

### Desktop Testing
- Use mouse and keyboard for basic interaction testing
- WASD movement, mouse look simulation
- Click objects to trigger interactions
- Press R to restart, ESC to quit

## Assessment Ideas

### Student Evaluation Criteria
- **Technical Skills**: VR setup, scripting, debugging
- **Creativity**: Custom features and extensions
- **Problem Solving**: Troubleshooting and optimization
- **Presentation**: Demonstrating projects to peers

### Project Rubric Example
| Criteria | Beginner (1-2) | Intermediate (3-4) | Advanced (5) |
|----------|----------------|-------------------|--------------|
| **VR Setup** | Runs basic tutorial | Customizes interactions | Creates new mechanics |
| **Scripting** | Modifies existing code | Writes new functions | Implements advanced systems |
| **Design** | Changes colors/positions | Adds new objects | Creates complete environments |
| **Innovation** | Follows instructions | Makes creative additions | Develops original concepts |

## License & Credits

This project is designed for educational use in schools and learning environments.

**Created for STEM Education** - Teaching VR development through hands-on projects

**Built with Open Source Tools**:
- Godot Engine (MIT License)
- OpenXR Standard
- Community contributions welcome

---
