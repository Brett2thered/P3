//
//  Session.swift
//  P3DrumMachine
//
//  Created on 2025-11-22.
//  Step 1: Shared Models & App State
//

import Foundation

/// Represents a complete session with all pads, settings, and state
struct Session: Codable, Identifiable {
    let id: UUID
    var name: String
    var bpm: Double
    var createdAt: Date
    var modifiedAt: Date

    // Grid configuration
    var rows: Int
    var columns: Int
    var pads: [Pad]

    // Visual customization
    var visualSettings: VisualSettings

    // Performance state (not persisted in some cases)
    var activeInstrumentPadID: UUID?
    var recordings: [Recording]

    init(
        id: UUID = UUID(),
        name: String = "New Session",
        bpm: Double = 102.0,
        rows: Int = 5,
        columns: Int = 8,
        createdAt: Date = Date(),
        modifiedAt: Date = Date(),
        visualSettings: VisualSettings = VisualSettings(),
        activeInstrumentPadID: UUID? = nil
    ) {
        self.id = id
        self.name = name
        self.bpm = bpm
        self.rows = rows
        self.columns = columns
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.visualSettings = visualSettings
        self.activeInstrumentPadID = activeInstrumentPadID
        self.recordings = []

        // Initialize pads grid
        var pads: [Pad] = []
        for row in 0..<rows {
            for col in 0..<columns {
                pads.append(Pad(row: row, column: col))
            }
        }
        self.pads = pads
    }

    // MARK: - Computed Properties

    var totalPads: Int {
        rows * columns
    }

    var assignedPads: [Pad] {
        pads.filter { !$0.isEmpty }
    }

    var emptyPads: [Pad] {
        pads.filter { $0.isEmpty }
    }

    // MARK: - Pad Access

    func pad(at row: Int, column: Int) -> Pad? {
        pads.first { $0.row == row && $0.column == column }
    }

    func pad(withID id: UUID) -> Pad? {
        pads.first { $0.id == id }
    }

    mutating func updatePad(_ pad: Pad) {
        if let index = pads.firstIndex(where: { $0.id == pad.id }) {
            pads[index] = pad
            modifiedAt = Date()
        }
    }

    mutating func updatePad(id: UUID, transform: (inout Pad) -> Void) {
        if let index = pads.firstIndex(where: { $0.id == id }) {
            transform(&pads[index])
            modifiedAt = Date()
        }
    }

    // MARK: - Grid Resizing

    mutating func resize(rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns

        // Preserve existing pads that fit in new grid
        var newPads: [Pad] = []
        for row in 0..<rows {
            for col in 0..<columns {
                if let existingPad = pad(at: row, column: col) {
                    newPads.append(existingPad)
                } else {
                    newPads.append(Pad(row: row, column: col))
                }
            }
        }
        pads = newPads
        modifiedAt = Date()
    }

    // MARK: - BPM

    mutating func setBPM(_ newBPM: Double) {
        bpm = min(max(newBPM, 20.0), 300.0) // Clamp to reasonable range
        modifiedAt = Date()
    }

    mutating func adjustBPM(_ delta: Double) {
        setBPM(bpm + delta)
    }

    // MARK: - Recordings

    mutating func addRecording(_ recording: Recording) {
        recordings.append(recording)
        modifiedAt = Date()
    }
}

/// Summary representation of a session for list views
struct SessionSummary: Identifiable, Codable {
    let id: UUID
    let name: String
    let createdAt: Date
    let modifiedAt: Date
    let bpm: Double
    let assignedPadsCount: Int

    init(from session: Session) {
        self.id = session.id
        self.name = session.name
        self.createdAt = session.createdAt
        self.modifiedAt = session.modifiedAt
        self.bpm = session.bpm
        self.assignedPadsCount = session.assignedPads.count
    }

    init(id: UUID, name: String, createdAt: Date, modifiedAt: Date, bpm: Double, assignedPadsCount: Int) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.bpm = bpm
        self.assignedPadsCount = assignedPadsCount
    }
}

/// Represents a recorded session output
struct Recording: Codable, Identifiable {
    let id: UUID
    var name: String
    var fileURL: URL
    var duration: TimeInterval
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        fileURL: URL,
        duration: TimeInterval,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.fileURL = fileURL
        self.duration = duration
        self.createdAt = createdAt
    }
}
