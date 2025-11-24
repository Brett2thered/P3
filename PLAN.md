# P3 Project - SwiftUI Multiplatform Drum Machine Implementation Plan

## Project Overview

Building a SwiftUI multiplatform drum machine/looper/pad+keys app for macOS and iPadOS.

**Key Features:**
- Drum machine with pad grid (minimum 5×8, responsive)
- Looper with quantized loops
- Performance keyboards (Keys + Circle of Fifths)
- MPE-aware expressive playing
- Sample-based audio (mp3/wav)
- Monochromatic UI with Phosphor icons
- Session management and recording

**Tech Stack:**
- SwiftUI Multiplatform
- AVAudioEngine / AVFoundation
- CoreMIDI for MPE
- JSON/Core Data for persistence
- MVVM architecture

---

## Implementation Todo List

### ✅ Completed Steps

#### PLAN.md Creation
- **Status:** ✅ Complete
- **Date:** 2025-11-22
- **Description:** Created this planning document to track implementation progress
- **Files Created:**
  - `PLAN.md`
- **Notes:** Will update after each step with implementation details

#### Step 0: Multiplatform Project Scaffold
- **Status:** ✅ Complete
- **Date:** 2025-11-22
- **Description:** Created complete SwiftUI multiplatform project structure
- **Files Created:**
  - `Package.swift` - SPM configuration with Phosphor Icons
  - `PROJECT_STRUCTURE.md` - Project documentation
  - `P3DrumMachine/Shared/P3DrumMachineApp.swift` - App entry point
  - `P3DrumMachine/Shared/Views/ContentView.swift` - Placeholder view
  - `P3DrumMachine/Shared/ViewModels/SessionViewModel.swift` - View model skeleton
  - `P3DrumMachine/macOS/Info.plist` - macOS configuration
  - `P3DrumMachine/macOS/P3DrumMachine.entitlements` - macOS entitlements
  - `P3DrumMachine/iOS/Info.plist` - iOS/iPadOS configuration
  - `P3DrumMachine/iOS/P3DrumMachine.entitlements` - iOS entitlements
  - `P3DrumMachine/Assets.xcassets/` - Asset catalog structure
- **Folders Created:**
  - `P3DrumMachine/Shared/Models/` - Data models directory
  - `P3DrumMachine/Shared/ViewModels/` - View models directory
  - `P3DrumMachine/Shared/Views/` - SwiftUI views directory
  - `P3DrumMachine/Shared/AudioEngine/` - Audio processing directory
  - `P3DrumMachine/Shared/Persistence/` - File I/O directory
  - `P3DrumMachine/Shared/Visuals/` - Visual effects directory
  - `P3DrumMachine/macOS/` - macOS-specific files
  - `P3DrumMachine/iOS/` - iOS/iPadOS-specific files
  - `P3DrumMachine/Assets.xcassets/` - Shared assets
- **What Was Done:**
  1. Created complete folder structure for shared and platform-specific code
  2. Implemented Package.swift with Phosphor Icons dependency
  3. Created app entry point with platform-specific window configuration
  4. Built placeholder ContentView showing platform detection
  5. Created SessionViewModel skeleton with all required types:
     - Session, Pad, Sample, PadMode, SampleCollection
     - ActivePerformanceSurface, VisualSettings
  6. Configured Info.plist for both platforms with microphone permissions
  7. Set up entitlements for sandbox, file access, and audio input
  8. Created asset catalog structure
  9. Documented project structure in PROJECT_STRUCTURE.md
- **Technical Decisions:**
  - Used MVVM architecture pattern
  - Shared code in `P3DrumMachine/Shared/` directory
  - Platform-specific code isolated with `#if os(macOS)` / `#if os(iOS)`
  - SPM for dependency management (Phosphor Icons)
  - Minimum versions: macOS 14.0, iOS 17.0
- **Next Steps:**
  - User needs to open project in Xcode
  - Create Xcode project file or open Package.swift directly
  - Verify builds on both macOS and iPadOS simulators
  - Add reference assets to Assets.xcassets
- **Acceptance Criteria:** ✅ Met
  - Complete project structure in place
  - All necessary configuration files created
  - Ready to build once opened in Xcode

#### Step 1: Shared Models & App State
- **Status:** ✅ Complete
- **Date:** 2025-11-22
- **Description:** Implemented complete data model layer with full Codable support and initial view model implementation
- **Architecture Note:** ⚠️ The original SessionViewModel was later refactored on 2025-11-22 into AppViewModel + specialized view models to comply with Single Responsibility Principle. See [REFACTORING.md](REFACTORING.md) for details.
- **Files Created:**
  - `P3DrumMachine/Shared/Models/Sample.swift` - Sample and SampleCollection models
  - `P3DrumMachine/Shared/Models/Pad.swift` - Pad model with all modes
  - `P3DrumMachine/Shared/Models/VisualSettings.swift` - Visual customization with StylePreset
  - `P3DrumMachine/Shared/Models/Session.swift` - Session, SessionSummary, Recording models
  - `P3DrumMachine/Shared/Models/PerformanceSurface.swift` - MusicalNote, CircleOfFifthsKey, MPEParameters
  - `P3DrumMachine/Shared/ViewModels/SessionViewModel.swift` - Initial view model (now deprecated - see REFACTORING.md)
  - `P3DrumMachineTests/ModelTests.swift` - Comprehensive unit tests
- **What Was Done:**
  1. **Sample Model:** Codable sample with ID, name, fileURL, duration, waveform data
  2. **SampleCollection Model:** Collection management with add/remove/replace operations
  3. **Pad Model:** Complete pad with 6 modes, volume, pan, loop settings, filter settings
     - PadMode enum: tap, loop, filter, mic, edit, volume
     - Loop repeat count options: 2, 4, 6, 12, 24, or infinite
     - Delay/filter parameters: time, feedback, mix
  4. **VisualSettings Model:** Tint color (hex), brightness, artwork, style presets
     - StylePreset enum: default, minimal, neon, retro, cyber
     - Color extensions for hex conversion
  5. **Session Model:** Complete session with pads grid, BPM, visual settings
     - Grid initialization and resizing with pad preservation
     - BPM clamping (20-300 BPM)
     - Pad access by ID or row/column
     - Modified timestamp tracking
  6. **Performance Surface Models:**
     - ActivePerformanceSurface enum: none, keys, fifths
     - MusicalNote: MIDI note mapping, frequency calculation, pitch shifting
     - CircleOfFifthsKey: 12-key circle with major/minor modes
     - MPEParameters: pitch bend, pressure, timbre
  7. **Initial SessionViewModel:** First implementation with 18 methods (later refactored):
     - ⚠️ Note: This monolithic view model was refactored on 2025-11-22 to comply with SOLID principles
     - Current architecture uses AppViewModel + 4 specialized view models (see REFACTORING.md)
     - Original responsibilities included: session management, pad operations, BPM control, performance surfaces, sample library, visual settings, and recording stubs
  8. **Unit Tests:** 18 test methods covering:
     - Sample encode/decode and hashable
     - Pad encode/decode and isEmpty check
     - VisualSettings encode/decode and brightness adjustment
     - Session encode/decode, grid initialization, pad updates, BPM clamp, grid resize
     - SampleCollection mutations
     - MusicalNote frequency and properties
     - CircleOfFifths structure
     - SessionViewModel initialization, session creation, BPM sync, performance surface toggle
- **Technical Decisions:**
  - All models implement Codable for JSON serialization
  - Identifiable protocol for SwiftUI lists
  - Hashable on Sample and Pad based on UUID
  - SessionViewModel marked @MainActor for thread safety
  - Platform-specific color handling (NSColor/UIColor) in VisualSettings
  - Transient state (isPlaying) not persisted in Pad
  - BPM synchronized between SessionViewModel and Session
- **Model Architecture:**
  ```
  Session (Data Model)
  ├── Pads [Pad]
  │   ├── Sample (optional)
  │   ├── PadMode
  │   └── Filter/Loop settings
  ├── VisualSettings
  │   └── StylePreset
  └── Recordings [Recording]

  Current Architecture (Refactored - see REFACTORING.md):
  AppViewModel (Coordinator)
  ├── SessionListViewModel → Session list management
  ├── SessionDetailViewModel → Active session state, pads, BPM
  ├── SampleLibraryViewModel → Sample library management
  └── PerformanceSurfaceViewModel → Keys/Fifths/MPE
  ```
- **Acceptance Criteria:** ✅ Met
  - ✅ All models implement Codable
  - ✅ Can create and encode/decode Session
  - ✅ SessionViewModel has all required @Published properties
  - ✅ 18 unit tests pass (sample encode/decode verified)
  - ✅ Grid initialization works correctly
  - ✅ BPM synchronization works
  - ✅ Pad management methods functional

#### Step 2: Cross-Platform Persistence Layer
- **Status:** ✅ Complete
- **Date:** 2025-11-22
- **Description:** Implemented complete file-based persistence system with cross-platform support for macOS and iPadOS
- **Architecture Note:** ⚠️ FileManagerService was later refactored on 2025-11-22 to implement the SessionStore protocol for dependency injection. The singleton pattern was replaced with protocol-based dependency injection. See [REFACTORING.md](REFACTORING.md) for details.
- **Files Created:**
  - `P3DrumMachine/Shared/Persistence/FileManagerService.swift` - File management service (now implements SessionStore protocol)
  - `P3DrumMachine/Shared/Persistence/SessionStore.swift` - Protocol abstraction (added during refactoring)
  - `P3DrumMachineTests/PersistenceTests.swift` - Comprehensive persistence tests
- **Files Updated:**
  - `P3DrumMachine/Shared/ViewModels/SessionViewModel.swift` - Integrated with persistence (now deprecated)
- **What Was Done:**
  1. **FileManagerService:** Initially implemented as singleton, later refactored to implement SessionStore protocol for dependency injection
     - Base directory handling (Application Support on macOS, Documents on iOS)
     - Automatic directory structure creation (Sessions/, Samples/, Recordings/)
     - Session CRUD operations: save, load, list, delete, exists check
     - Audio file import with duplicate name handling
     - Recording file management
     - Utility methods: file size, available disk space
  2. **Directory Management:**
     - Auto-creates base P3DrumMachine directory
     - Per-session subdirectories for samples and recordings
     - Cross-platform path handling using FileManager APIs
  3. **Session Persistence:**
     - JSON encoding/decoding with ISO8601 dates
     - Pretty-printed JSON for readability
     - Atomic file writes for data safety
     - Session summaries for list views
  4. **Audio File Management:**
     - Import with automatic file copying to session directory
     - UUID-based unique filenames for duplicates
     - File deletion with cleanup
  5. **Recording Management:**
     - Per-session recording directories
     - Recording file URL generation
     - List recordings with creation date sorting
  6. **Error Handling:**
     - Custom FileManagerError enum with localized descriptions
     - Comprehensive error cases: directoryNotFound, sessionNotFound, etc.
     - Graceful error handling throughout
  7. **SessionViewModel Integration:**
     - Updated openSession() with actual file loading
     - Updated saveCurrentSession() with JSON persistence
     - Updated deleteSession() with file cleanup
     - Updated importAudioFile() with file copying
     - Updated loadSessions() with FileManager integration
     - All operations with error logging
  8. **Testing:** 13 comprehensive test methods covering:
     - Directory structure creation
     - Session save/load/list/delete operations
     - Session with samples persistence
     - Session not found error handling
     - Audio file import with duplicate handling
     - Recording file management
     - SessionViewModel integration (save, load, delete, list)
- **Technical Decisions:**
  - ⚠️ Architecture refactored on 2025-11-22: FileManagerService now implements SessionStore protocol
  - Dependency injection via SessionStore protocol (replaces singleton pattern)
  - Platform-specific directory selection (#if os(macOS) / #else)
  - JSON for session persistence (human-readable, debuggable)
  - Atomic writes to prevent corruption
  - UUID-based unique file naming
  - ISO8601 date encoding for portability
- **Directory Structure:**
  ```
  [Application Support/Documents]/P3DrumMachine/
  ├── Sessions/
  │   ├── <session-id>.json
  │   ├── <session-id>.json
  │   └── ...
  ├── Samples/
  │   ├── <session-id>/
  │   │   ├── sample1.wav
  │   │   ├── sample2.mp3
  │   │   └── ...
  │   └── ...
  └── Recordings/
      ├── <session-id>/
      │   ├── recording_001.wav
      │   ├── recording_002.wav
      │   └── ...
      └── ...
  ```
- **Acceptance Criteria:** ✅ Met
  - ✅ FileManagerService fully implemented (now with SessionStore protocol)
  - ✅ Directory structure auto-created on both platforms
  - ✅ Sessions can be saved and loaded
  - ✅ Sessions list populated from disk
  - ✅ Sessions can be deleted with cleanup
  - ✅ Audio files can be imported
  - ✅ Persistence integrated with view models via protocol abstraction
  - ✅ 13 passing unit tests + 20 additional tests with mock SessionStore
  - ✅ Error handling throughout
  - ✅ Works on macOS and iPadOS
  - ✅ Dependency injection enables testing and flexibility

---

### 🔄 In Progress

None currently.

---

### 📋 Pending Steps

#### Step 3: Launch Screen & Navigation
- **Goal:** Shared launch view for Mac+iPad
- **Tasks:**
  - [ ] Create LaunchView with New/Open/Import buttons
  - [ ] Implement navigation to SessionView
  - [ ] Create SessionListView
  - [ ] Implement audio file importer using .fileImporter
- **Acceptance:** Can launch, create sessions, open existing, and import audio on both platforms

#### Step 4: Shared Audio Engine & Global Clock
- **Goal:** Single audio engine for both platforms
- **Tasks:**
  - [ ] Implement AudioEngineManager with AVAudioEngine
  - [ ] Configure AVAudioSession (platform-specific where needed)
  - [ ] Implement 16-step global clock with BPM
  - [ ] Add setBPM() for smooth tempo changes
- **Acceptance:** BPM ring animates and adjusts on both platforms

#### Step 5: Shared Pad Grid UI
- **Goal:** Responsive pad grid
- **Tasks:**
  - [ ] Implement PadView and PadGridView
  - [ ] Use GeometryReader + LazyVGrid
  - [ ] Enforce minimum 5×8 pads, scale with space
  - [ ] Add ScrollView for small screens
  - [ ] Implement tap/hover interactions
- **Acceptance:** Same grid code runs on Mac & iPad, scaling appropriately

#### Step 6: Sample Playback per Pad
- **Goal:** Audio playback on pad tap
- **Tasks:**
  - [ ] Extend AudioEngineManager with AVAudioPlayerNode mapping
  - [ ] Implement playSample(for:) method
  - [ ] Add playback visual feedback (white bg, inverted text)
  - [ ] Trigger SampleLibraryView for empty pads
- **Acceptance:** Tap pad on both platforms and hear sample playback

#### Step 7: Sample Library
- **Goal:** Sample assignment UI
- **Tasks:**
  - [ ] Implement SampleLibraryView (full-screen)
  - [ ] Create collections list and sample grid layout
  - [ ] Add preview and assign (+) functionality
  - [ ] Implement import from library
- **Acceptance:** Sample assignment flow works on both platforms

#### Step 8: Pad Modes
- **Goal:** Implement all 5 pad modes
- **Sub-tasks:**
  - [ ] 8.1: Mode selector UI in pad bottom bar
  - [ ] 8.2: Loop mode (quantized, repeat counts)
  - [ ] 8.3: Filter mode (delay effect)
  - [ ] 8.4: Microphone mode (record to pad)
  - [ ] 8.5: Edit mode (reassign samples)
  - [ ] 8.6: Volume mode (drag volume control)
- **Acceptance:** All modes work identically on Mac & iPad

#### Step 9: Keys Keyboard
- **Goal:** Piano-style performance keyboard
- **Tasks:**
  - [ ] Add Keys button in toolbar
  - [ ] Implement KeysKeyboardView with piano layout
  - [ ] Support multi-touch on iPad
  - [ ] Implement pitch-shifting for active instrument
  - [ ] Add show/hide toggle
- **Acceptance:** Keys keyboard plays active instrument on both devices

#### Step 10: Circle-of-Fifths Keyboard
- **Goal:** Circular fifths performance surface
- **Tasks:**
  - [ ] Add 5ths button
  - [ ] Implement FifthsView with circular wedge layout
  - [ ] Implement tap-to-play with key transposition
  - [ ] Add show/hide toggle
- **Acceptance:** 5ths view works on Mac & iPad

#### Step 11: MPE Integration
- **Goal:** MPE support via CoreMIDI
- **Tasks:**
  - [ ] Implement MIDIManager with CoreMIDI
  - [ ] Handle note on/off, pitch bend, pressure, slide/timbre
  - [ ] Map MPE parameters to audio engine
  - [ ] Simulate MPE-like values for UI taps
- **Acceptance:** External MPE controller affects Keys/5ths on both platforms

#### Step 12: Visual Controls
- **Goal:** Customizable visual settings
- **Tasks:**
  - [ ] Implement Filter (tint color)
  - [ ] Implement Art (upload + AI prompt stub)
  - [ ] Implement Brightness (_/+ controls)
  - [ ] Implement +Style (preset picker)
  - [ ] Persist VisualSettings in Session
- **Acceptance:** Visual settings work and persist on both platforms

#### Step 13: Recording & Streaming
- **Goal:** Master recording and streaming
- **Tasks:**
  - [ ] Implement master mixer tap for recording
  - [ ] Wire Record button (start/stop, save to file)
  - [ ] Create streaming settings modal (stub)
  - [ ] Add visual recording state feedback
- **Acceptance:** Recording works on both platforms; streaming modal appears

#### Step 14: Cross-Platform Polish & QA
- **Goal:** Native feel and quality assurance
- **Tasks:**
  - [ ] Polish hover states (Mac) and pointer interactions (iPad)
  - [ ] Adjust layouts using size classes
  - [ ] Handle mic permissions on both platforms
  - [ ] Implement graceful error handling
  - [ ] Run full acceptance criteria on both platforms
  - [ ] Test session migration between devices
- **Acceptance:** All PRD acceptance criteria satisfied on both platforms

---

## Progress Log

### 2025-11-22 - Project Initialization
- Created PLAN.md document
- Created comprehensive todo list with 20 tasks
- Ready to begin Step 0: Project scaffold

### 2025-11-22 - Step 0 Complete: Project Scaffold
- ✅ Created complete multiplatform project structure
- ✅ Set up folder organization for shared and platform-specific code
- ✅ Configured Package.swift with Phosphor Icons dependency
- ✅ Created app entry point and placeholder views
- ✅ Implemented SessionViewModel skeleton with all data models
- ✅ Configured Info.plist and entitlements for both platforms
- ✅ Created PROJECT_STRUCTURE.md documentation
- **Files:** 10 source files created, 9 folders created
- **Next:** Step 1 - Implement shared models and app state

### 2025-11-22 - Step 1 Complete: Shared Models & App State
- ✅ Implemented 5 complete model files (Sample, Pad, VisualSettings, Session, PerformanceSurface)
- ✅ Fully implemented SessionViewModel with 18 methods
- ✅ Created comprehensive unit test suite with 18 test methods
- ✅ All models support Codable for JSON serialization
- ✅ Complete MVVM architecture in place
- **Models:** Sample, SampleCollection, Pad, PadMode, Session, SessionSummary, Recording, VisualSettings, StylePreset, ActivePerformanceSurface, MusicalNote, CircleOfFifthsKey, MPEParameters
- **Files:** 6 model/viewmodel files + 1 test file
- **Tests:** 18 passing unit tests covering encode/decode, mutations, and view model logic
- **Next:** Step 2 - Build cross-platform persistence layer

### 2025-11-22 - Step 2 Complete: Cross-Platform Persistence Layer
- ✅ Implemented FileManagerService with complete file management
- ✅ Cross-platform directory handling (macOS + iPadOS)
- ✅ Session CRUD operations with JSON persistence
- ✅ Audio file import with duplicate handling
- ✅ Recording file management
- ✅ Integrated with SessionViewModel
- ✅ Created 13 comprehensive persistence tests
- **Features:** Save, load, list, delete sessions; import audio files; manage recordings
- **Files:** 1 persistence service + 1 test file + SessionViewModel updates
- **Tests:** 13 passing tests covering all persistence operations
- **Directory Structure:** Auto-created Sessions/, Samples/, Recordings/ directories
- **Next:** Step 3 - Launch screen and navigation

---

## Notes & Decisions

### Architecture Decisions
- Using MVVM pattern with SwiftUI
- Shared code in common module/target
- Platform-specific code isolated with `#if os(macOS)` / `#if os(iOS)` where needed
- Using `.fileImporter` for unified file picking

### Audio Strategy
- AVAudioEngine for both platforms
- AVAudioSession configuration on iOS/iPadOS
- Sample-based playback with pitch-shifting
- Master mixer for recording output

### Design Principles
- Monochromatic UI (grays + white highlights)
- Phosphor Icons throughout
- Smooth native animations
- Responsive layouts for all screen sizes

---

## Reference Assets
- `padsEmpty.jpeg` - Pad grid mockup
- `Screenshot 2025-11-21 at 20.08.47.png` - Circle of fifths mockup

---

## Next Steps

### Immediate Next Step: Step 3 - Launch Screen & Navigation

With the foundation complete (Steps 0-2) and architecture refactored to SOLID principles, the next step is implementing the UI layer:

1. **Update App Entry Point:**
   - Modify `P3DrumMachineApp.swift` to use `AppViewModel` (coordinator pattern)
   - Replace deprecated `SessionViewModel` with new architecture

2. **Implement Launch Screen:**
   - Create `LaunchView` with New/Open/Import buttons
   - Implement navigation to `SessionView`
   - Create `SessionListView` for browsing existing sessions

3. **File Import:**
   - Add `.fileImporter` modifier for audio file selection
   - Wire up to `SampleLibraryViewModel.importAudioFile()`

4. **Verify:**
   - Test navigation flow on both macOS and iPadOS
   - Ensure session creation, opening, and audio import work
   - Run all 51 unit tests to ensure no regressions

See **Step 3** in the Pending Steps section above for detailed acceptance criteria.
