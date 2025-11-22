//
//  ModelTests.swift
//  P3DrumMachineTests
//
//  Created on 2025-11-22.
//  Step 1: Model validation tests
//

import XCTest
@testable import P3DrumMachine

final class ModelTests: XCTestCase {

    // MARK: - Sample Tests

    func testSampleEncodeDecode() throws {
        let url = URL(fileURLWithPath: "/tmp/test.wav")
        let sample = Sample(
            name: "Kick",
            fileURL: url,
            duration: 1.5
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(sample)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Sample.self, from: data)

        XCTAssertEqual(sample.id, decoded.id)
        XCTAssertEqual(sample.name, decoded.name)
        XCTAssertEqual(sample.fileURL, decoded.fileURL)
        XCTAssertEqual(sample.duration, decoded.duration)
    }

    func testSampleHashable() {
        let url = URL(fileURLWithPath: "/tmp/test.wav")
        let sample1 = Sample(id: UUID(), name: "Kick", fileURL: url)
        let sample2 = Sample(id: sample1.id, name: "Snare", fileURL: url)

        XCTAssertEqual(sample1, sample2) // Same ID = equal
    }

    // MARK: - Pad Tests

    func testPadEncodeDecode() throws {
        let url = URL(fileURLWithPath: "/tmp/kick.wav")
        let sample = Sample(name: "Kick", fileURL: url)
        var pad = Pad(row: 0, column: 0)
        pad.sample = sample
        pad.mode = .loop
        pad.volume = 0.8
        pad.loopRepeatCount = 4

        let encoder = JSONEncoder()
        let data = try encoder.encode(pad)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Pad.self, from: data)

        XCTAssertEqual(pad.id, decoded.id)
        XCTAssertEqual(pad.sample?.id, decoded.sample?.id)
        XCTAssertEqual(pad.mode, decoded.mode)
        XCTAssertEqual(pad.volume, decoded.volume)
        XCTAssertEqual(pad.loopRepeatCount, decoded.loopRepeatCount)
        XCTAssertEqual(pad.row, decoded.row)
        XCTAssertEqual(pad.column, decoded.column)
        XCTAssertFalse(decoded.isPlaying) // Should always be false when decoded
    }

    func testPadIsEmpty() {
        let pad = Pad(row: 0, column: 0)
        XCTAssertTrue(pad.isEmpty)

        var assignedPad = Pad(row: 0, column: 0)
        assignedPad.sample = Sample(name: "Test", fileURL: URL(fileURLWithPath: "/tmp/test.wav"))
        XCTAssertFalse(assignedPad.isEmpty)
    }

    // MARK: - VisualSettings Tests

    func testVisualSettingsEncodeDecode() throws {
        var settings = VisualSettings()
        settings.tintColorHex = "#00FF00"
        settings.brightness = 0.7
        settings.stylePreset = .neon

        let encoder = JSONEncoder()
        let data = try encoder.encode(settings)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(VisualSettings.self, from: data)

        XCTAssertEqual(settings.tintColorHex, decoded.tintColorHex)
        XCTAssertEqual(settings.brightness, decoded.brightness)
        XCTAssertEqual(settings.stylePreset, decoded.stylePreset)
    }

    func testVisualSettingsBrightnessAdjustment() {
        var settings = VisualSettings()
        settings.brightness = 0.5

        settings.adjustBrightness(0.3)
        XCTAssertEqual(settings.brightness, 0.8, accuracy: 0.01)

        settings.adjustBrightness(0.5) // Should clamp to 1.0
        XCTAssertEqual(settings.brightness, 1.0)

        settings.adjustBrightness(-1.5) // Should clamp to 0.0
        XCTAssertEqual(settings.brightness, 0.0)
    }

    // MARK: - Session Tests

    func testSessionEncodeDecode() throws {
        let session = Session(
            name: "Test Session",
            bpm: 120.0,
            rows: 5,
            columns: 8
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(session)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Session.self, from: data)

        XCTAssertEqual(session.id, decoded.id)
        XCTAssertEqual(session.name, decoded.name)
        XCTAssertEqual(session.bpm, decoded.bpm)
        XCTAssertEqual(session.rows, decoded.rows)
        XCTAssertEqual(session.columns, decoded.columns)
        XCTAssertEqual(session.pads.count, decoded.pads.count)
    }

    func testSessionPadGridInitialization() {
        let session = Session(rows: 5, columns: 8)

        XCTAssertEqual(session.pads.count, 40) // 5 * 8
        XCTAssertEqual(session.totalPads, 40)

        // Verify all positions are filled
        for row in 0..<5 {
            for col in 0..<8 {
                let pad = session.pad(at: row, column: col)
                XCTAssertNotNil(pad)
                XCTAssertEqual(pad?.row, row)
                XCTAssertEqual(pad?.column, col)
            }
        }
    }

    func testSessionUpdatePad() {
        var session = Session(rows: 3, columns: 3)
        let padID = session.pads[0].id

        session.updatePad(id: padID) { pad in
            pad.volume = 0.5
            pad.mode = .loop
        }

        let updatedPad = session.pad(withID: padID)
        XCTAssertEqual(updatedPad?.volume, 0.5)
        XCTAssertEqual(updatedPad?.mode, .loop)
    }

    func testSessionBPMClamp() {
        var session = Session()

        session.setBPM(500.0) // Too high
        XCTAssertEqual(session.bpm, 300.0)

        session.setBPM(10.0) // Too low
        XCTAssertEqual(session.bpm, 20.0)

        session.setBPM(120.0) // Valid
        XCTAssertEqual(session.bpm, 120.0)
    }

    func testSessionGridResize() {
        var session = Session(rows: 3, columns: 3)
        let firstPadID = session.pads[0].id

        // Assign a sample to first pad
        var firstPad = session.pads[0]
        firstPad.sample = Sample(name: "Test", fileURL: URL(fileURLWithPath: "/tmp/test.wav"))
        session.updatePad(firstPad)

        // Resize to larger grid
        session.resize(rows: 5, columns: 5)

        XCTAssertEqual(session.pads.count, 25)
        XCTAssertEqual(session.totalPads, 25)

        // First pad should still exist with its sample
        let preservedPad = session.pad(withID: firstPadID)
        XCTAssertNotNil(preservedPad)
        XCTAssertNotNil(preservedPad?.sample)
    }

    // MARK: - SampleCollection Tests

    func testSampleCollectionMutations() {
        var collection = SampleCollection(name: "Test")

        let sample1 = Sample(name: "S1", fileURL: URL(fileURLWithPath: "/tmp/s1.wav"))
        let sample2 = Sample(name: "S2", fileURL: URL(fileURLWithPath: "/tmp/s2.wav"))

        collection.add(sample: sample1)
        collection.add(sample: sample2)
        XCTAssertEqual(collection.samples.count, 2)

        collection.remove(sampleID: sample1.id)
        XCTAssertEqual(collection.samples.count, 1)
        XCTAssertEqual(collection.samples.first?.id, sample2.id)
    }

    // MARK: - PerformanceSurface Tests

    func testMusicalNoteFrequency() {
        let a4 = MusicalNote(midiNote: 69) // A4 = 440 Hz
        XCTAssertEqual(a4.frequency, 440.0, accuracy: 0.1)

        let c4 = MusicalNote(midiNote: 60) // Middle C
        XCTAssertEqual(c4.frequency, 261.63, accuracy: 0.1)
    }

    func testMusicalNoteProperties() {
        let c4 = MusicalNote(midiNote: 60)
        XCTAssertEqual(c4.name, "C4")
        XCTAssertFalse(c4.isBlackKey)

        let cs4 = MusicalNote(midiNote: 61)
        XCTAssertEqual(cs4.name, "C#4")
        XCTAssertTrue(cs4.isBlackKey)
    }

    func testCircleOfFifths() {
        let circle = CircleOfFifthsKey.circleOfFifths
        XCTAssertEqual(circle.count, 12)
        XCTAssertEqual(circle[0].rootNote, "C")
        XCTAssertEqual(circle[1].rootNote, "G")
    }

    // MARK: - SessionViewModel Tests

    func testSessionViewModelInitialization() {
        let vm = SessionViewModel()

        XCTAssertNil(vm.currentSession)
        XCTAssertEqual(vm.bpm, 102.0)
        XCTAssertEqual(vm.activePerformanceSurface, .none)
        XCTAssertFalse(vm.isRecording)
        XCTAssertEqual(vm.sampleLibrary.count, 4) // Drums, Bass, Synth, User Imports
    }

    func testSessionViewModelNewSession() {
        let vm = SessionViewModel()
        vm.newSession(name: "Test", rows: 6, columns: 10)

        XCTAssertNotNil(vm.currentSession)
        XCTAssertEqual(vm.currentSession?.name, "Test")
        XCTAssertEqual(vm.currentSession?.rows, 6)
        XCTAssertEqual(vm.currentSession?.columns, 10)
        XCTAssertEqual(vm.currentSession?.pads.count, 60)
    }

    func testSessionViewModelBPMSync() {
        let vm = SessionViewModel()
        vm.newSession()

        vm.setBPM(140.0)
        XCTAssertEqual(vm.bpm, 140.0)
        XCTAssertEqual(vm.currentSession?.bpm, 140.0)

        vm.adjustBPM(10.0)
        XCTAssertEqual(vm.bpm, 150.0)
    }

    func testSessionViewModelSixteenthNoteDuration() {
        let vm = SessionViewModel()
        vm.setBPM(120.0)

        let duration = vm.sixteenthNoteDuration()
        // At 120 BPM: 60 / (120 * 4) = 0.125 seconds
        XCTAssertEqual(duration, 0.125, accuracy: 0.001)
    }

    func testSessionViewModelPerformanceSurfaceToggle() {
        let vm = SessionViewModel()

        vm.toggleKeys()
        XCTAssertEqual(vm.activePerformanceSurface, .keys)

        vm.toggleKeys()
        XCTAssertEqual(vm.activePerformanceSurface, .none)

        vm.toggleFifths()
        XCTAssertEqual(vm.activePerformanceSurface, .fifths)

        vm.toggleFifths()
        XCTAssertEqual(vm.activePerformanceSurface, .none)
    }

    func testSessionViewModelPadManagement() {
        let vm = SessionViewModel()
        vm.newSession()

        guard let firstPad = vm.currentSession?.pads.first else {
            XCTFail("No pads in session")
            return
        }

        let sample = Sample(name: "Kick", fileURL: URL(fileURLWithPath: "/tmp/kick.wav"))
        vm.assignSample(sample, toPad: firstPad.id)

        let updatedPad = vm.pad(withID: firstPad.id)
        XCTAssertEqual(updatedPad?.sample?.name, "Kick")
    }
}
