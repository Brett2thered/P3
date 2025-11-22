//
//  Sample.swift
//  P3DrumMachine
//
//  Created on 2025-11-22.
//  Step 1: Shared Models & App State
//

import Foundation

/// Represents an audio sample that can be assigned to a pad
struct Sample: Codable, Identifiable, Hashable {
    let id: UUID
    var name: String
    var fileURL: URL
    var duration: TimeInterval?
    var waveformData: Data? // For visual representation

    init(
        id: UUID = UUID(),
        name: String,
        fileURL: URL,
        duration: TimeInterval? = nil,
        waveformData: Data? = nil
    ) {
        self.id = id
        self.name = name
        self.fileURL = fileURL
        self.duration = duration
        self.waveformData = waveformData
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case fileURL
        case duration
        case waveformData
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        fileURL = try container.decode(URL.self, forKey: .fileURL)
        duration = try container.decodeIfPresent(TimeInterval.self, forKey: .duration)
        waveformData = try container.decodeIfPresent(Data.self, forKey: .waveformData)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(fileURL, forKey: .fileURL)
        try container.encodeIfPresent(duration, forKey: .duration)
        try container.encodeIfPresent(waveformData, forKey: .waveformData)
    }

    // MARK: - Hashable

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Sample, rhs: Sample) -> Bool {
        lhs.id == rhs.id
    }
}

/// Collection of samples (e.g., "Drums", "Bass", "User Imports")
struct SampleCollection: Identifiable, Codable {
    let id: UUID
    var name: String
    var samples: [Sample]
    var isUserCollection: Bool // User-created vs. default collections

    init(
        id: UUID = UUID(),
        name: String,
        samples: [Sample] = [],
        isUserCollection: Bool = false
    ) {
        self.id = id
        self.name = name
        self.samples = samples
        self.isUserCollection = isUserCollection
    }

    // MARK: - Mutations

    mutating func add(sample: Sample) {
        samples.append(sample)
    }

    mutating func remove(sampleID: UUID) {
        samples.removeAll { $0.id == sampleID }
    }

    mutating func replace(sampleID: UUID, with newSample: Sample) {
        if let index = samples.firstIndex(where: { $0.id == sampleID }) {
            samples[index] = newSample
        }
    }
}
