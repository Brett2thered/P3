//
//  FileManagerService.swift
//  P3DrumMachine
//
//  Created on 2025-11-22.
//  Step 2: Cross-Platform Persistence Layer
//

import Foundation

/// Cross-platform file management service for sessions, samples, and recordings
/// Works on both macOS and iPadOS using FileManager APIs
class FileManagerService {

    // MARK: - Singleton

    static let shared = FileManagerService()

    // MARK: - Properties

    private let fileManager = FileManager.default
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    // MARK: - Directory URLs

    /// Base application support directory (cross-platform)
    private var baseDirectory: URL {
        get throws {
            #if os(macOS)
            guard let url = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
                throw FileManagerError.directoryNotFound
            }
            return url.appendingPathComponent("P3DrumMachine", isDirectory: true)
            #else
            guard let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
                throw FileManagerError.directoryNotFound
            }
            return url.appendingPathComponent("P3DrumMachine", isDirectory: true)
            #endif
        }
    }

    /// Sessions directory
    var sessionsDirectory: URL {
        get throws {
            try baseDirectory.appendingPathComponent("Sessions", isDirectory: true)
        }
    }

    /// Samples directory
    var samplesDirectory: URL {
        get throws {
            try baseDirectory.appendingPathComponent("Samples", isDirectory: true)
        }
    }

    /// Recordings directory
    var recordingsDirectory: URL {
        get throws {
            try baseDirectory.appendingPathComponent("Recordings", isDirectory: true)
        }
    }

    // MARK: - Initialization

    private init() {
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        decoder.dateDecodingStrategy = .iso8601

        // Create directory structure on initialization
        do {
            try createDirectoryStructure()
        } catch {
            print("⚠️ Failed to create directory structure: \(error)")
        }
    }

    // MARK: - Directory Management

    /// Create the base directory structure
    private func createDirectoryStructure() throws {
        let directories = [
            try baseDirectory,
            try sessionsDirectory,
            try samplesDirectory,
            try recordingsDirectory
        ]

        for directory in directories {
            if !fileManager.fileExists(atPath: directory.path) {
                try fileManager.createDirectory(
                    at: directory,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
                print("📁 Created directory: \(directory.lastPathComponent)")
            }
        }
    }

    /// Create session-specific directories
    func createSessionDirectories(sessionID: UUID) throws {
        let sessionSamplesDir = try samplesDirectory.appendingPathComponent(sessionID.uuidString, isDirectory: true)
        let sessionRecordingsDir = try recordingsDirectory.appendingPathComponent(sessionID.uuidString, isDirectory: true)

        for directory in [sessionSamplesDir, sessionRecordingsDir] {
            if !fileManager.fileExists(atPath: directory.path) {
                try fileManager.createDirectory(
                    at: directory,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
            }
        }
    }

    // MARK: - Session Management

    /// Save a session to disk
    func saveSession(_ session: Session) throws {
        let sessionURL = try sessionFileURL(for: session.id)

        // Create session directories if needed
        try createSessionDirectories(sessionID: session.id)

        // Encode session to JSON
        let data = try encoder.encode(session)

        // Write to file
        try data.write(to: sessionURL, options: [.atomic])

        print("💾 Saved session: \(session.name) (\(session.id))")
    }

    /// Load a session from disk
    func loadSession(id: UUID) throws -> Session {
        let sessionURL = try sessionFileURL(for: id)

        guard fileManager.fileExists(atPath: sessionURL.path) else {
            throw FileManagerError.sessionNotFound(id)
        }

        let data = try Data(contentsOf: sessionURL)
        let session = try decoder.decode(Session.self, from: data)

        print("📂 Loaded session: \(session.name) (\(session.id))")
        return session
    }

    /// List all saved sessions
    func listSessions() throws -> [SessionSummary] {
        let directory = try sessionsDirectory

        guard fileManager.fileExists(atPath: directory.path) else {
            return []
        }

        let fileURLs = try fileManager.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: [.creationDateKey, .contentModificationDateKey],
            options: [.skipsHiddenFiles]
        )

        var summaries: [SessionSummary] = []

        for fileURL in fileURLs where fileURL.pathExtension == "json" {
            do {
                let session = try loadSession(id: UUID(uuidString: fileURL.deletingPathExtension().lastPathComponent)!)
                summaries.append(SessionSummary(from: session))
            } catch {
                print("⚠️ Failed to load session summary from \(fileURL.lastPathComponent): \(error)")
            }
        }

        // Sort by most recently modified
        return summaries.sorted { $0.modifiedAt > $1.modifiedAt }
    }

    /// Delete a session and its associated files
    func deleteSession(id: UUID) throws {
        let sessionURL = try sessionFileURL(for: id)

        // Delete session file
        if fileManager.fileExists(atPath: sessionURL.path) {
            try fileManager.removeItem(at: sessionURL)
        }

        // Delete session samples directory
        let sessionSamplesDir = try samplesDirectory.appendingPathComponent(id.uuidString, isDirectory: true)
        if fileManager.fileExists(atPath: sessionSamplesDir.path) {
            try fileManager.removeItem(at: sessionSamplesDir)
        }

        // Delete session recordings directory
        let sessionRecordingsDir = try recordingsDirectory.appendingPathComponent(id.uuidString, isDirectory: true)
        if fileManager.fileExists(atPath: sessionRecordingsDir.path) {
            try fileManager.removeItem(at: sessionRecordingsDir)
        }

        print("🗑️ Deleted session: \(id)")
    }

    /// Check if a session exists
    func sessionExists(id: UUID) -> Bool {
        do {
            let sessionURL = try sessionFileURL(for: id)
            return fileManager.fileExists(atPath: sessionURL.path)
        } catch {
            return false
        }
    }

    // MARK: - Sample Management

    /// Copy an audio file into the samples directory for a session
    func importAudioFile(from sourceURL: URL, sessionID: UUID, name: String? = nil) throws -> URL {
        // Determine destination filename
        let filename = name ?? sourceURL.lastPathComponent
        let destinationURL = try samplesDirectory
            .appendingPathComponent(sessionID.uuidString, isDirectory: true)
            .appendingPathComponent(filename)

        // Create session samples directory if needed
        try createSessionDirectories(sessionID: sessionID)

        // Copy file
        if fileManager.fileExists(atPath: destinationURL.path) {
            // File already exists, generate unique name
            let uniqueFilename = "\(UUID().uuidString)_\(filename)"
            let uniqueURL = try samplesDirectory
                .appendingPathComponent(sessionID.uuidString, isDirectory: true)
                .appendingPathComponent(uniqueFilename)
            try fileManager.copyItem(at: sourceURL, to: uniqueURL)
            print("📥 Imported audio: \(uniqueFilename)")
            return uniqueURL
        } else {
            try fileManager.copyItem(at: sourceURL, to: destinationURL)
            print("📥 Imported audio: \(filename)")
            return destinationURL
        }
    }

    /// Delete an audio file
    func deleteAudioFile(at url: URL) throws {
        if fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
            print("🗑️ Deleted audio file: \(url.lastPathComponent)")
        }
    }

    // MARK: - Recording Management

    /// Get recording file URL for a session
    func recordingFileURL(sessionID: UUID, filename: String) throws -> URL {
        try recordingsDirectory
            .appendingPathComponent(sessionID.uuidString, isDirectory: true)
            .appendingPathComponent(filename)
    }

    /// List all recordings for a session
    func listRecordings(sessionID: UUID) throws -> [URL] {
        let sessionRecordingsDir = try recordingsDirectory
            .appendingPathComponent(sessionID.uuidString, isDirectory: true)

        guard fileManager.fileExists(atPath: sessionRecordingsDir.path) else {
            return []
        }

        let fileURLs = try fileManager.contentsOfDirectory(
            at: sessionRecordingsDir,
            includingPropertiesForKeys: [.creationDateKey],
            options: [.skipsHiddenFiles]
        )

        return fileURLs.sorted {
            (try? $0.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? Date() >
            (try? $1.resourceValues(forKeys: [.creationDateKey]).creationDate) ?? Date()
        }
    }

    // MARK: - Utility Methods

    /// Get file URL for a session
    private func sessionFileURL(for id: UUID) throws -> URL {
        try sessionsDirectory.appendingPathComponent("\(id.uuidString).json")
    }

    /// Get file size in bytes
    func fileSize(at url: URL) -> Int64? {
        guard let attributes = try? fileManager.attributesOfItem(atPath: url.path) else {
            return nil
        }
        return attributes[.size] as? Int64
    }

    /// Get available disk space in bytes
    func availableDiskSpace() -> Int64? {
        do {
            let systemAttributes = try fileManager.attributesOfFileSystem(forPath: NSHomeDirectory())
            return systemAttributes[.systemFreeSize] as? Int64
        } catch {
            return nil
        }
    }
}

// MARK: - Errors

enum FileManagerError: LocalizedError {
    case directoryNotFound
    case sessionNotFound(UUID)
    case invalidSessionFile
    case insufficientDiskSpace
    case fileOperationFailed(String)

    var errorDescription: String? {
        switch self {
        case .directoryNotFound:
            return "Could not locate application directory"
        case .sessionNotFound(let id):
            return "Session not found: \(id)"
        case .invalidSessionFile:
            return "Session file is invalid or corrupted"
        case .insufficientDiskSpace:
            return "Insufficient disk space"
        case .fileOperationFailed(let operation):
            return "File operation failed: \(operation)"
        }
    }
}
