//
//  PersistenceTests.swift
//  P3DrumMachineTests
//
//  Created on 2025-11-22.
//  Step 2: Persistence layer validation tests
//

import XCTest
@testable import P3DrumMachine

final class PersistenceTests: XCTestCase {

    var fileManager: FileManagerService!

    override func setUp() {
        super.setUp()
        fileManager = FileManagerService.shared
    }

    override func tearDown() {
        // Clean up test sessions
        do {
            let sessions = try fileManager.listSessions()
            for session in sessions {
                try? fileManager.deleteSession(id: session.id)
            }
        } catch {
            print("Cleanup failed: \(error)")
        }
        super.tearDown()
    }

    // MARK: - Directory Structure Tests

    func testDirectoryCreation() throws {
        let sessionsDir = try fileManager.sessionsDirectory
        let samplesDir = try fileManager.samplesDirectory
        let recordingsDir = try fileManager.recordingsDirectory

        XCTAssertTrue(FileManager.default.fileExists(atPath: sessionsDir.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: samplesDir.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: recordingsDir.path))
    }

    // MARK: - Session Save/Load Tests

    func testSaveSession() throws {
        var session = Session(name: "Test Session", bpm: 120.0)
        session.pads[0].sample = Sample(
            name: "Kick",
            fileURL: URL(fileURLWithPath: "/tmp/kick.wav")
        )

        try fileManager.saveSession(session)

        XCTAssertTrue(fileManager.sessionExists(id: session.id))
    }

    func testLoadSession() throws {
        // Create and save session
        let originalSession = Session(name: "Load Test", bpm: 140.0, rows: 6, columns: 10)
        try fileManager.saveSession(originalSession)

        // Load session
        let loadedSession = try fileManager.loadSession(id: originalSession.id)

        XCTAssertEqual(loadedSession.id, originalSession.id)
        XCTAssertEqual(loadedSession.name, originalSession.name)
        XCTAssertEqual(loadedSession.bpm, originalSession.bpm)
        XCTAssertEqual(loadedSession.rows, originalSession.rows)
        XCTAssertEqual(loadedSession.columns, originalSession.columns)
        XCTAssertEqual(loadedSession.pads.count, originalSession.pads.count)
    }

    func testSaveAndLoadSessionWithSamples() throws {
        // Create session with sample
        var session = Session(name: "Session With Samples")
        let sample = Sample(
            name: "Test Sample",
            fileURL: URL(fileURLWithPath: "/tmp/test.wav"),
            duration: 1.5
        )
        session.pads[0].sample = sample
        session.pads[0].mode = .loop
        session.pads[0].volume = 0.7
        session.pads[0].loopRepeatCount = 4

        // Save
        try fileManager.saveSession(session)

        // Load
        let loadedSession = try fileManager.loadSession(id: session.id)

        XCTAssertNotNil(loadedSession.pads[0].sample)
        XCTAssertEqual(loadedSession.pads[0].sample?.name, "Test Sample")
        XCTAssertEqual(loadedSession.pads[0].mode, .loop)
        XCTAssertEqual(loadedSession.pads[0].volume, 0.7)
        XCTAssertEqual(loadedSession.pads[0].loopRepeatCount, 4)
    }

    func testListSessions() throws {
        // Create multiple sessions
        let session1 = Session(name: "Session 1")
        let session2 = Session(name: "Session 2")
        let session3 = Session(name: "Session 3")

        try fileManager.saveSession(session1)
        try fileManager.saveSession(session2)
        try fileManager.saveSession(session3)

        // List sessions
        let sessions = try fileManager.listSessions()

        XCTAssertGreaterThanOrEqual(sessions.count, 3)
        XCTAssertTrue(sessions.contains { $0.id == session1.id })
        XCTAssertTrue(sessions.contains { $0.id == session2.id })
        XCTAssertTrue(sessions.contains { $0.id == session3.id })
    }

    func testDeleteSession() throws {
        // Create and save session
        let session = Session(name: "Delete Test")
        try fileManager.saveSession(session)

        XCTAssertTrue(fileManager.sessionExists(id: session.id))

        // Delete session
        try fileManager.deleteSession(id: session.id)

        XCTAssertFalse(fileManager.sessionExists(id: session.id))
    }

    func testSessionNotFound() {
        let nonExistentID = UUID()

        XCTAssertThrowsError(try fileManager.loadSession(id: nonExistentID)) { error in
            if case FileManagerError.sessionNotFound(let id) = error {
                XCTAssertEqual(id, nonExistentID)
            } else {
                XCTFail("Expected sessionNotFound error")
            }
        }
    }

    // MARK: - Sample Import Tests

    func testImportAudioFile() throws {
        let session = Session(name: "Import Test")
        try fileManager.saveSession(session)

        // Create a temporary file to import
        let tempDir = FileManager.default.temporaryDirectory
        let tempFile = tempDir.appendingPathComponent("test_sample.wav")
        try "Test audio data".write(to: tempFile, atomically: true, encoding: .utf8)

        // Import file
        let importedURL = try fileManager.importAudioFile(
            from: tempFile,
            sessionID: session.id,
            name: "test_sample.wav"
        )

        XCTAssertTrue(FileManager.default.fileExists(atPath: importedURL.path))
        XCTAssertEqual(importedURL.lastPathComponent, "test_sample.wav")

        // Cleanup
        try? FileManager.default.removeItem(at: tempFile)
    }

    func testImportAudioFileDuplicateName() throws {
        let session = Session(name: "Duplicate Import Test")
        try fileManager.saveSession(session)

        // Create a temporary file
        let tempDir = FileManager.default.temporaryDirectory
        let tempFile = tempDir.appendingPathComponent("duplicate.wav")
        try "Test audio data".write(to: tempFile, atomically: true, encoding: .utf8)

        // Import same file twice
        let import1 = try fileManager.importAudioFile(
            from: tempFile,
            sessionID: session.id,
            name: "duplicate.wav"
        )
        let import2 = try fileManager.importAudioFile(
            from: tempFile,
            sessionID: session.id,
            name: "duplicate.wav"
        )

        // Second import should have a different (unique) filename
        XCTAssertNotEqual(import1.lastPathComponent, import2.lastPathComponent)
        XCTAssertTrue(FileManager.default.fileExists(atPath: import1.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: import2.path))

        // Cleanup
        try? FileManager.default.removeItem(at: tempFile)
    }

    // MARK: - Recording Management Tests

    func testRecordingFileURL() throws {
        let session = Session(name: "Recording Test")
        try fileManager.saveSession(session)

        let recordingURL = try fileManager.recordingFileURL(
            sessionID: session.id,
            filename: "recording_001.wav"
        )

        XCTAssertTrue(recordingURL.path.contains(session.id.uuidString))
        XCTAssertEqual(recordingURL.lastPathComponent, "recording_001.wav")
    }

    func testListRecordings() throws {
        let session = Session(name: "List Recordings Test")
        try fileManager.saveSession(session)

        // Create some recording files
        let recording1 = try fileManager.recordingFileURL(sessionID: session.id, filename: "rec1.wav")
        let recording2 = try fileManager.recordingFileURL(sessionID: session.id, filename: "rec2.wav")

        try "Recording 1".write(to: recording1, atomically: true, encoding: .utf8)
        try "Recording 2".write(to: recording2, atomically: true, encoding: .utf8)

        // List recordings
        let recordings = try fileManager.listRecordings(sessionID: session.id)

        XCTAssertEqual(recordings.count, 2)
        XCTAssertTrue(recordings.contains { $0.lastPathComponent == "rec1.wav" })
        XCTAssertTrue(recordings.contains { $0.lastPathComponent == "rec2.wav" })
    }

    // MARK: - SessionViewModel Integration Tests

    @MainActor
    func testSessionViewModelSaveAndLoad() {
        let viewModel = SessionViewModel()

        // Create new session
        viewModel.newSession(name: "ViewModel Test", rows: 6, columns: 8)
        guard let sessionID = viewModel.currentSession?.id else {
            XCTFail("Session not created")
            return
        }

        // Save session
        viewModel.saveCurrentSession()

        // Create new view model and load session
        let viewModel2 = SessionViewModel()
        viewModel2.openSession(id: sessionID)

        XCTAssertNotNil(viewModel2.currentSession)
        XCTAssertEqual(viewModel2.currentSession?.name, "ViewModel Test")
        XCTAssertEqual(viewModel2.currentSession?.rows, 6)
        XCTAssertEqual(viewModel2.currentSession?.columns, 8)
    }

    @MainActor
    func testSessionViewModelDelete() {
        let viewModel = SessionViewModel()

        // Create and save session
        viewModel.newSession(name: "Delete Test")
        guard let sessionID = viewModel.currentSession?.id else {
            XCTFail("Session not created")
            return
        }
        viewModel.saveCurrentSession()

        // Verify it exists
        XCTAssertTrue(fileManager.sessionExists(id: sessionID))

        // Delete
        viewModel.deleteSession(id: sessionID)

        // Verify deleted
        XCTAssertFalse(fileManager.sessionExists(id: sessionID))
    }

    @MainActor
    func testSessionViewModelListSessions() {
        let viewModel = SessionViewModel()

        // Create multiple sessions
        viewModel.newSession(name: "List Test 1")
        viewModel.saveCurrentSession()

        viewModel.newSession(name: "List Test 2")
        viewModel.saveCurrentSession()

        viewModel.newSession(name: "List Test 3")
        viewModel.saveCurrentSession()

        // Check sessions list
        XCTAssertGreaterThanOrEqual(viewModel.sessions.count, 3)
    }
}
