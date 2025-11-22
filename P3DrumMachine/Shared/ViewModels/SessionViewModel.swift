//
//  SessionViewModel.swift
//  P3DrumMachine
//
//  Created on 2025-11-22.
//  Step 1: Shared Models & App State - FULLY IMPLEMENTED
//  Step 2: Integrated with FileManagerService
//

import SwiftUI
import Combine

/// Main view model managing the application state
/// Handles session management, sample library, and performance surfaces
@MainActor
class SessionViewModel: ObservableObject {

    // MARK: - Published Properties

    /// Current active session
    @Published var currentSession: Session?

    /// List of all saved sessions
    @Published var sessions: [SessionSummary] = []

    /// Sample library collections
    @Published var sampleLibrary: [SampleCollection] = []

    /// Active performance surface (none, keys, or fifths)
    @Published var activePerformanceSurface: ActivePerformanceSurface = .none

    /// ID of the pad designated as the active instrument for Keys/5ths
    @Published var activeInstrumentPadID: UUID?

    /// Global BPM (synchronized with current session)
    @Published var bpm: Double = 102.0 {
        didSet {
            currentSession?.setBPM(bpm)
        }
    }

    /// Current step in 16-step sequencer (0-15)
    @Published var currentStep: Int = 0

    /// Recording state
    @Published var isRecording: Bool = false

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()
    private let fileManager = FileManagerService.shared

    // MARK: - Initialization

    init() {
        setupDefaultSampleLibrary()
        loadSessions()
    }

    // MARK: - Session Management

    /// Create a new session
    func newSession(name: String = "New Session", rows: Int = 5, columns: Int = 8) {
        let session = Session(
            name: name,
            bpm: 102.0,
            rows: rows,
            columns: columns
        )
        currentSession = session
        bpm = session.bpm
    }

    /// Open an existing session
    func openSession(id: UUID) {
        do {
            let session = try fileManager.loadSession(id: id)
            currentSession = session
            bpm = session.bpm
            activeInstrumentPadID = session.activeInstrumentPadID
            print("✅ Opened session: \(session.name)")
        } catch {
            print("❌ Failed to open session: \(error.localizedDescription)")
        }
    }

    /// Save current session
    func saveCurrentSession() {
        guard let session = currentSession else {
            print("⚠️ No active session to save")
            return
        }

        do {
            try fileManager.saveSession(session)
            // Refresh sessions list
            loadSessions()
        } catch {
            print("❌ Failed to save session: \(error.localizedDescription)")
        }
    }

    /// Delete a session
    func deleteSession(id: UUID) {
        do {
            try fileManager.deleteSession(id: id)
            sessions.removeAll { $0.id == id }
            print("✅ Deleted session: \(id)")
        } catch {
            print("❌ Failed to delete session: \(error.localizedDescription)")
        }
    }

    /// Close current session
    func closeCurrentSession() {
        saveCurrentSession()
        currentSession = nil
        activePerformanceSurface = .none
        activeInstrumentPadID = nil
    }

    // MARK: - Pad Management

    /// Get pad by ID
    func pad(withID id: UUID) -> Pad? {
        currentSession?.pad(withID: id)
    }

    /// Update a pad
    func updatePad(_ pad: Pad) {
        currentSession?.updatePad(pad)
    }

    /// Update pad with transform closure
    func updatePad(id: UUID, transform: (inout Pad) -> Void) {
        currentSession?.updatePad(id: id, transform: transform)
    }

    /// Assign sample to pad
    func assignSample(_ sample: Sample, toPad padID: UUID) {
        updatePad(id: padID) { pad in
            pad.sample = sample
        }
    }

    /// Set pad mode
    func setPadMode(_ mode: PadMode, forPad padID: UUID) {
        updatePad(id: padID) { pad in
            pad.mode = mode
        }
    }

    /// Set active instrument pad for Keys/5ths
    func setActiveInstrument(padID: UUID?) {
        activeInstrumentPadID = padID
        currentSession?.activeInstrumentPadID = padID
    }

    // MARK: - Grid Management

    /// Resize the pad grid
    func resizeGrid(rows: Int, columns: Int) {
        currentSession?.resize(rows: rows, columns: columns)
    }

    // MARK: - BPM Management

    /// Set BPM value
    func setBPM(_ newBPM: Double) {
        bpm = newBPM
    }

    /// Adjust BPM by delta
    func adjustBPM(_ delta: Double) {
        setBPM(bpm + delta)
    }

    /// Get duration of one 16th note in seconds
    func sixteenthNoteDuration() -> TimeInterval {
        60.0 / (bpm * 4.0)
    }

    // MARK: - Performance Surface Management

    /// Show Keys keyboard
    func showKeys() {
        activePerformanceSurface = .keys
    }

    /// Show Circle of Fifths keyboard
    func showFifths() {
        activePerformanceSurface = .fifths
    }

    /// Hide performance keyboard
    func hidePerformanceSurface() {
        activePerformanceSurface = .none
    }

    /// Toggle Keys keyboard
    func toggleKeys() {
        if activePerformanceSurface == .keys {
            activePerformanceSurface = .none
        } else {
            activePerformanceSurface = .keys
        }
    }

    /// Toggle Circle of Fifths keyboard
    func toggleFifths() {
        if activePerformanceSurface == .fifths {
            activePerformanceSurface = .none
        } else {
            activePerformanceSurface = .fifths
        }
    }

    // MARK: - Sample Library Management

    /// Add a sample to a collection
    func addSample(_ sample: Sample, toCollection collectionID: UUID) {
        if let index = sampleLibrary.firstIndex(where: { $0.id == collectionID }) {
            sampleLibrary[index].add(sample: sample)
        }
    }

    /// Remove a sample from a collection
    func removeSample(sampleID: UUID, fromCollection collectionID: UUID) {
        if let index = sampleLibrary.firstIndex(where: { $0.id == collectionID }) {
            sampleLibrary[index].remove(sampleID: sampleID)
        }
    }

    /// Create a new sample collection
    func createCollection(name: String) {
        let collection = SampleCollection(name: name, isUserCollection: true)
        sampleLibrary.append(collection)
    }

    /// Import audio file into User Imports collection
    func importAudioFile(url: URL) {
        guard let session = currentSession else {
            print("⚠️ No active session for import")
            return
        }

        do {
            // Copy file to session samples directory
            let destinationURL = try fileManager.importAudioFile(
                from: url,
                sessionID: session.id,
                name: url.lastPathComponent
            )

            // Create sample
            let sample = Sample(name: url.deletingPathExtension().lastPathComponent, fileURL: destinationURL)

            // Find or create "User Imports" collection
            if let userImportsIndex = sampleLibrary.firstIndex(where: { $0.name == "User Imports" }) {
                sampleLibrary[userImportsIndex].add(sample: sample)
            } else {
                var userImports = SampleCollection(name: "User Imports", isUserCollection: true)
                userImports.add(sample: sample)
                sampleLibrary.append(userImports)
            }

            print("✅ Imported audio: \(sample.name)")
        } catch {
            print("❌ Failed to import audio: \(error.localizedDescription)")
        }
    }

    // MARK: - Visual Settings

    /// Update visual settings
    func updateVisualSettings(_ settings: VisualSettings) {
        currentSession?.visualSettings = settings
    }

    /// Set tint color
    func setTintColor(_ color: Color) {
        currentSession?.visualSettings.setTintColor(color)
    }

    /// Adjust brightness
    func adjustBrightness(_ delta: Double) {
        currentSession?.visualSettings.adjustBrightness(delta)
    }

    /// Set style preset
    func setStylePreset(_ preset: StylePreset) {
        currentSession?.visualSettings.stylePreset = preset
    }

    // MARK: - Recording

    /// Start recording master output
    func startRecording() {
        // Will be implemented in Step 13
        isRecording = true
        print("Recording started")
    }

    /// Stop recording and save
    func stopRecording() {
        // Will be implemented in Step 13
        isRecording = false
        print("Recording stopped")
    }

    // MARK: - Private Methods

    private func setupDefaultSampleLibrary() {
        // Create default collections
        let drums = SampleCollection(name: "Drums", isUserCollection: false)
        let bass = SampleCollection(name: "Bass", isUserCollection: false)
        let synth = SampleCollection(name: "Synth", isUserCollection: false)
        let userImports = SampleCollection(name: "User Imports", isUserCollection: true)

        sampleLibrary = [drums, bass, synth, userImports]
    }

    private func loadSessions() {
        do {
            sessions = try fileManager.listSessions()
            print("📂 Loaded \(sessions.count) session(s)")
        } catch {
            print("❌ Failed to load sessions: \(error.localizedDescription)")
            sessions = []
        }
    }
}

// MARK: - Debug Helpers

#if DEBUG
extension SessionViewModel {
    /// Create a sample session for testing
    static func sample() -> SessionViewModel {
        let vm = SessionViewModel()
        vm.newSession(name: "Test Session")
        return vm
    }
}
#endif
