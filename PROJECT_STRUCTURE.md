# P3 Drum Machine - Project Structure

## Overview

This is a SwiftUI multiplatform project targeting macOS and iPadOS with shared code.

## Directory Structure

```
P3/
├── README.md                          # Project overview
├── PLAN.md                            # Implementation plan and progress tracking
├── PROJECT_STRUCTURE.md               # This file
├── Package.swift                      # SPM dependencies (Phosphor Icons)
└── P3DrumMachine/                     # Main app directory
    ├── Shared/                        # Shared code for both platforms
    │   ├── P3DrumMachineApp.swift    # App entry point
    │   ├── Models/                    # Data models
    │   ├── ViewModels/                # View models (MVVM)
    │   │   └── SessionViewModel.swift
    │   ├── Views/                     # SwiftUI views
    │   │   └── ContentView.swift
    │   ├── AudioEngine/               # Audio processing
    │   ├── Persistence/               # File I/O and session management
    │   └── Visuals/                   # Visual effects and theming
    ├── macOS/                         # macOS-specific files
    │   ├── Info.plist
    │   └── P3DrumMachine.entitlements
    ├── iOS/                           # iOS/iPadOS-specific files
    │   ├── Info.plist
    │   └── P3DrumMachine.entitlements
    └── Assets.xcassets/               # Shared assets
        ├── AppIcon.appiconset/
        └── ReferenceAssets.imageset/
```

## Opening in Xcode

### Method 1: Create Xcode Project (Recommended)

1. Open Xcode
2. File > New > Project
3. Choose "Multiplatform > App"
4. Name: "P3DrumMachine"
5. Interface: SwiftUI
6. Language: Swift
7. Save in: `/Users/b/Documents/cld_ppl/P3/`
8. **Replace the generated files** with the files in this repository
9. Add SPM dependency:
   - File > Add Package Dependencies
   - URL: `https://github.com/phosphor-icons/swift`
   - Version: 2.0.0 or later

### Method 2: Use Package.swift Directly

1. Open Terminal
2. Navigate to project: `cd /Users/b/Documents/cld_ppl/P3`
3. Open in Xcode: `open Package.swift`
4. Xcode will create a workspace automatically

### Setting Up Targets

The project requires two targets:

1. **macOS App**
   - Bundle ID: `com.p3.drummachine.macos`
   - Minimum Version: macOS 14.0
   - Entitlements: sandbox, file access, audio input
   - Info.plist: `P3DrumMachine/macOS/Info.plist`

2. **iPadOS App**
   - Bundle ID: `com.p3.drummachine.ios`
   - Minimum Version: iOS 17.0
   - Supports: iPad only (all orientations)
   - Info.plist: `P3DrumMachine/iOS/Info.plist`

## Build Configuration

### Shared Code
- All files in `P3DrumMachine/Shared/` are compiled for both targets
- Use `#if os(macOS)` / `#if os(iOS)` for platform-specific code

### Dependencies
- **Phosphor Icons**: Icon system (SPM)
- **AVFoundation**: Audio engine
- **CoreMIDI**: MPE/MIDI support
- **SwiftUI**: UI framework

## Current Status

**Step 0: Project Scaffold** ✅ Complete

The basic project structure is in place with:
- Shared folder structure
- Platform-specific Info.plist and entitlements
- Package.swift for dependencies
- Placeholder app entry point and ContentView
- Basic SessionViewModel structure

## Next Steps

1. Open project in Xcode
2. Verify builds for both macOS and iPadOS
3. Proceed to Step 1: Implement shared models and app state

## Reference Assets

Place the following reference assets in `Assets.xcassets/ReferenceAssets.imageset/`:
- `padsEmpty.jpeg` - Pad grid mockup
- `Screenshot 2025-11-21 at 20.08.47.png` - Circle of fifths mockup

## Build & Run

### macOS
```bash
xcodebuild -scheme P3DrumMachine-macOS -destination 'platform=macOS' build
```

### iPadOS Simulator
```bash
xcodebuild -scheme P3DrumMachine-iOS -destination 'platform=iOS Simulator,name=iPad Pro (12.9-inch)' build
```

## Troubleshooting

### "Cannot find 'Phosphor' in scope"
- Ensure SPM dependencies are resolved
- Product > Clean Build Folder
- File > Packages > Resolve Package Versions

### Platform-specific compilation errors
- Check `#if os(macOS)` / `#if os(iOS)` conditionals
- Verify target membership for each file

### Audio permissions not working
- Check Info.plist has `NSMicrophoneUsageDescription`
- Verify entitlements include audio input capability
- Reset simulator: Device > Erase All Content and Settings
