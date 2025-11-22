//
//  Pad.swift
//  P3DrumMachine
//
//  Created on 2025-11-22.
//  Step 1: Shared Models & App State
//

import Foundation

/// Pad operating modes
enum PadMode: String, Codable, CaseIterable, Identifiable {
    case tap      // Simple one-shot playback
    case loop     // Quantized looping
    case filter   // Delay effect
    case mic      // Microphone recording
    case edit     // Reassign sample
    case volume   // Volume control

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .tap: return "Tap"
        case .loop: return "Loop"
        case .filter: return "Filter"
        case .mic: return "Mic"
        case .edit: return "Edit"
        case .volume: return "Volume"
        }
    }

    var iconName: String {
        // Phosphor icon names (will be used with Phosphor library)
        switch self {
        case .tap: return "hand.tap"
        case .loop: return "repeat"
        case .filter: return "waveform"
        case .mic: return "microphone"
        case .edit: return "pencil"
        case .volume: return "speaker.wave.3"
        }
    }
}

/// Represents a single pad in the grid
struct Pad: Codable, Identifiable, Hashable {
    let id: UUID
    var sample: Sample?
    var mode: PadMode
    var volume: Double // 0.0 to 1.0
    var pan: Double // -1.0 (left) to 1.0 (right)

    // Loop mode properties
    var isLooping: Bool
    var loopRepeatCount: Int? // 2, 4, 6, 12, or 24 (nil = infinite)

    // Filter mode properties
    var filterEnabled: Bool
    var delayTime: TimeInterval // Delay in seconds
    var delayFeedback: Double // 0.0 to 1.0
    var delayMix: Double // 0.0 to 1.0

    // State
    var isPlaying: Bool // Transient state (not persisted)

    // Grid position (for layout)
    var row: Int
    var column: Int

    init(
        id: UUID = UUID(),
        sample: Sample? = nil,
        mode: PadMode = .tap,
        volume: Double = 1.0,
        pan: Double = 0.0,
        isLooping: Bool = false,
        loopRepeatCount: Int? = nil,
        filterEnabled: Bool = false,
        delayTime: TimeInterval = 0.25,
        delayFeedback: Double = 0.3,
        delayMix: Double = 0.5,
        isPlaying: Bool = false,
        row: Int,
        column: Int
    ) {
        self.id = id
        self.sample = sample
        self.mode = mode
        self.volume = volume
        self.pan = pan
        self.isLooping = isLooping
        self.loopRepeatCount = loopRepeatCount
        self.filterEnabled = filterEnabled
        self.delayTime = delayTime
        self.delayFeedback = delayFeedback
        self.delayMix = delayMix
        self.isPlaying = isPlaying
        self.row = row
        self.column = column
    }

    // MARK: - Computed Properties

    var isEmpty: Bool {
        sample == nil
    }

    var displayName: String {
        sample?.name ?? "Empty"
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case id
        case sample
        case mode
        case volume
        case pan
        case isLooping
        case loopRepeatCount
        case filterEnabled
        case delayTime
        case delayFeedback
        case delayMix
        case row
        case column
        // Note: isPlaying is not persisted
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        sample = try container.decodeIfPresent(Sample.self, forKey: .sample)
        mode = try container.decode(PadMode.self, forKey: .mode)
        volume = try container.decode(Double.self, forKey: .volume)
        pan = try container.decode(Double.self, forKey: .pan)
        isLooping = try container.decode(Bool.self, forKey: .isLooping)
        loopRepeatCount = try container.decodeIfPresent(Int.self, forKey: .loopRepeatCount)
        filterEnabled = try container.decode(Bool.self, forKey: .filterEnabled)
        delayTime = try container.decode(TimeInterval.self, forKey: .delayTime)
        delayFeedback = try container.decode(Double.self, forKey: .delayFeedback)
        delayMix = try container.decode(Double.self, forKey: .delayMix)
        row = try container.decode(Int.self, forKey: .row)
        column = try container.decode(Int.self, forKey: .column)
        isPlaying = false // Always false when loaded
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(sample, forKey: .sample)
        try container.encode(mode, forKey: .mode)
        try container.encode(volume, forKey: .volume)
        try container.encode(pan, forKey: .pan)
        try container.encode(isLooping, forKey: .isLooping)
        try container.encodeIfPresent(loopRepeatCount, forKey: .loopRepeatCount)
        try container.encode(filterEnabled, forKey: .filterEnabled)
        try container.encode(delayTime, forKey: .delayTime)
        try container.encode(delayFeedback, forKey: .delayFeedback)
        try container.encode(delayMix, forKey: .delayMix)
        try container.encode(row, forKey: .row)
        try container.encode(column, forKey: .column)
    }

    // MARK: - Hashable

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Pad, rhs: Pad) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Loop Repeat Count Options

extension Pad {
    static let loopRepeatOptions = [2, 4, 6, 12, 24]

    var loopRepeatDisplayName: String {
        guard let count = loopRepeatCount else {
            return "∞" // Infinite loop
        }
        return "\(count)"
    }
}
