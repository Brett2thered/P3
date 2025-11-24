# P3 Drum Machine

A professional SwiftUI multiplatform drum machine, looper, and performance pad application for macOS and iPadOS.

## Overview

P3 is a modern, MPE-aware audio production tool featuring:

- **Responsive Pad Grid** - Minimum 5×8 grid with tap/loop/filter/mic/edit/volume modes
- **Performance Keyboards** - Piano-style Keys keyboard and Circle of Fifths interface
- **Sample-based Audio** - Import and play mp3/wav samples with pitch-shifting
- **Quantized Looper** - Loop pads with configurable repeat counts (2, 4, 6, 12, 24, ∞)
- **MPE Support** - Full MPE (MIDI Polyphonic Expression) integration via CoreMIDI
- **Session Management** - Save, load, and manage multiple sessions with cross-platform persistence
- **Visual Customization** - Tint colors, brightness controls, and style presets
- **Recording & Streaming** - Master recording with streaming capabilities (planned)

## Tech Stack

- **SwiftUI** - Multiplatform UI framework
- **AVFoundation** - Audio engine and sample playback
- **CoreMIDI** - MPE/MIDI support for expressive control
- **MVVM Architecture** - SOLID-compliant with dependency injection
- **SPM** - Swift Package Manager for dependencies
- **Phosphor Icons** - Comprehensive icon system

## Project Status

**Foundation Complete** ✅ - Ready for UI implementation

- ✅ Steps 0-2: Project scaffold, data models, persistence layer
- ✅ Architecture refactored to SOLID principles (2025-11-22)
- ✅ 51 passing unit tests with comprehensive coverage
- ⏭️ Next: Step 3 - Launch screen & navigation

See [STATUS.md](STATUS.md) for detailed progress tracking.

## Architecture

**SOLID-Compliant MVVM with Dependency Injection:**

```
AppViewModel (Coordinator)
├── SessionListViewModel       → Session list management
├── SessionDetailViewModel     → Active session state, pads, BPM
├── SampleLibraryViewModel     → Sample library management
└── PerformanceSurfaceViewModel → Keys/Fifths/MPE

Data Layer:
├── SessionStore Protocol      → Persistence abstraction
└── FileManagerService         → Concrete implementation
```

See [REFACTORING.md](REFACTORING.md) for architecture details and design decisions.

## Quick Start

### Prerequisites

- **Xcode 15.0+** (for macOS 14.0+ and iOS 17.0+)
- **Swift 5.9+**
- **macOS or iPadOS device/simulator**

### Setup

1. **Clone the repository:**
   ```bash
   cd /path/to/P3
   ```

2. **Open in Xcode:**
   - Method 1: `open Package.swift` (Xcode will create workspace)
   - Method 2: Create new Xcode project and replace generated files

3. **Resolve dependencies:**
   - Xcode → File → Packages → Resolve Package Versions
   - Wait for Phosphor Icons SPM dependency to download

4. **Select target:**
   - **macOS:** Choose "P3DrumMachine-macOS" scheme
   - **iPadOS:** Choose "P3DrumMachine-iOS" scheme

5. **Build and run:**
   ```bash
   # macOS
   ⌘R (or xcodebuild -scheme P3DrumMachine-macOS)

   # iPadOS Simulator
   Select iPad simulator and ⌘R
   ```

### Running Tests

```bash
⌘U in Xcode
# or
xcodebuild test -scheme P3DrumMachine
```

**Expected:** All 51 tests pass (18 model + 13 persistence + 20 view model tests)

## Project Structure

```
P3/
├── README.md                    # This file
├── PLAN.md                      # Implementation roadmap
├── STATUS.md                    # Progress tracking
├── PROJECT_STRUCTURE.md         # Detailed structure docs
├── REFACTORING.md               # Architecture decisions
├── Package.swift                # SPM dependencies
└── P3DrumMachine/
    ├── Shared/                  # Cross-platform code
    │   ├── Models/              # 5 data model files
    │   ├── ViewModels/          # 5 specialized view models + 1 coordinator
    │   ├── Persistence/         # SessionStore protocol + FileManagerService
    │   ├── Views/               # SwiftUI views
    │   ├── AudioEngine/         # Audio processing (Step 4+)
    │   └── Visuals/             # Visual effects (Step 12+)
    ├── macOS/                   # macOS-specific files
    ├── iOS/                     # iPadOS-specific files
    └── Assets.xcassets/         # Shared assets
```

See [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md) for complete structure documentation.

## Documentation

- **[PLAN.md](PLAN.md)** - Detailed implementation plan with 14 steps
- **[STATUS.md](STATUS.md)** - Current progress and statistics
- **[PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md)** - Directory structure and build config
- **[REFACTORING.md](REFACTORING.md)** - Architecture refactoring and SOLID principles

## Development Roadmap

### Completed (Steps 0-2)
- ✅ Multiplatform project scaffold
- ✅ Data models with Codable support
- ✅ Cross-platform persistence layer
- ✅ SOLID-compliant architecture with DI

### In Progress
- 🔄 Step 3: Launch screen & navigation

### Upcoming
- 📋 Step 4: Audio engine & global clock
- 📋 Step 5: Pad grid UI
- 📋 Step 6: Sample playback
- 📋 Step 7-14: Features, modes, keyboards, polish

See [PLAN.md](PLAN.md) for complete roadmap.

## Key Features (Planned)

### Pad Modes
- **Tap** - One-shot sample playback
- **Loop** - Quantized looping with repeat counts
- **Filter** - Delay/filter effects (time, feedback, mix)
- **Microphone** - Record audio directly to pad
- **Edit** - Reassign samples from library
- **Volume** - Drag-to-adjust volume control

### Performance Surfaces
- **Keys Keyboard** - Piano-style layout with pitch-shifting
- **Circle of Fifths** - Circular wedge interface with key transposition
- **MPE Integration** - Pitch bend, pressure, timbre (slide) via CoreMIDI

### Visual Settings
- **Filter** - Tint color customization
- **Art** - Custom artwork upload + AI prompt (planned)
- **Brightness** - Adjustable brightness levels
- **Style Presets** - default, minimal, neon, retro, cyber

## Cross-Platform Support

- **macOS 14.0+** - Full desktop experience with hover states
- **iPadOS 17.0+** - Touch-optimized with multi-touch support
- **Shared Codebase** - 95%+ code sharing via SwiftUI
- **Platform-specific** - Audio session config, file paths, UI adaptations

## Contributing

This is a personal project, but architecture feedback and suggestions are welcome.

## License

All rights reserved.

## Contact

For questions or feedback about the architecture or implementation, please open an issue.

---

**Current Version:** 0.3.0-alpha (Foundation Complete)
**Last Updated:** 2025-11-24
