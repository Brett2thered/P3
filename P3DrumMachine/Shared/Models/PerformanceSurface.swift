//
//  PerformanceSurface.swift
//  P3DrumMachine
//
//  Created on 2025-11-22.
//  Step 1: Shared Models & App State
//

import Foundation

/// Active performance surface (Keys or Circle of Fifths)
enum ActivePerformanceSurface: String, Codable {
    case none
    case keys
    case fifths

    var displayName: String {
        switch self {
        case .none: return "None"
        case .keys: return "Keys"
        case .fifths: return "5ths"
        }
    }

    var isActive: Bool {
        self != .none
    }
}

/// Musical note representation for Keys keyboard
struct MusicalNote: Identifiable {
    let id = UUID()
    let midiNote: Int // MIDI note number (0-127)
    let name: String // E.g., "C4", "F#5"
    let isBlackKey: Bool

    init(midiNote: Int) {
        self.midiNote = midiNote

        let noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
        let blackKeyNotes = [1, 3, 6, 8, 10] // Positions of black keys in octave

        let octave = (midiNote / 12) - 1
        let noteIndex = midiNote % 12
        self.name = "\(noteNames[noteIndex])\(octave)"
        self.isBlackKey = blackKeyNotes.contains(noteIndex)
    }

    var frequency: Double {
        // Convert MIDI note to frequency in Hz
        // A4 (MIDI 69) = 440 Hz
        440.0 * pow(2.0, Double(midiNote - 69) / 12.0)
    }

    var pitchShiftInSemitones: Double {
        Double(midiNote - 60) // Relative to C4 (middle C)
    }
}

/// Circle of Fifths key representation
struct CircleOfFifthsKey: Identifiable {
    let id = UUID()
    let rootNote: String // E.g., "C", "G", "D"
    let mode: KeyMode // Major or Minor
    let position: Int // 0-11 around the circle

    var displayName: String {
        "\(rootNote) \(mode.rawValue)"
    }

    var midiRootNote: Int {
        // Return MIDI note for root note in octave 4
        let noteToMidi: [String: Int] = [
            "C": 60, "G": 67, "D": 62, "A": 69, "E": 64,
            "B": 71, "F#": 66, "Db": 61, "Ab": 68, "Eb": 63,
            "Bb": 70, "F": 65
        ]
        return noteToMidi[rootNote] ?? 60
    }

    static let circleOfFifths: [CircleOfFifthsKey] = [
        CircleOfFifthsKey(rootNote: "C", mode: .major, position: 0),
        CircleOfFifthsKey(rootNote: "G", mode: .major, position: 1),
        CircleOfFifthsKey(rootNote: "D", mode: .major, position: 2),
        CircleOfFifthsKey(rootNote: "A", mode: .major, position: 3),
        CircleOfFifthsKey(rootNote: "E", mode: .major, position: 4),
        CircleOfFifthsKey(rootNote: "B", mode: .major, position: 5),
        CircleOfFifthsKey(rootNote: "F#", mode: .major, position: 6),
        CircleOfFifthsKey(rootNote: "Db", mode: .major, position: 7),
        CircleOfFifthsKey(rootNote: "Ab", mode: .major, position: 8),
        CircleOfFifthsKey(rootNote: "Eb", mode: .major, position: 9),
        CircleOfFifthsKey(rootNote: "Bb", mode: .major, position: 10),
        CircleOfFifthsKey(rootNote: "F", mode: .major, position: 11)
    ]
}

enum KeyMode: String {
    case major = "Major"
    case minor = "Minor"
}

/// MPE (MIDI Polyphonic Expression) parameters
struct MPEParameters {
    var pitchBend: Double // -1.0 to 1.0 (typically ±2 semitones)
    var pressure: Double // 0.0 to 1.0 (aftertouch)
    var timbre: Double // 0.0 to 1.0 (slide/brightness)

    static var `default`: MPEParameters {
        MPEParameters(pitchBend: 0.0, pressure: 0.7, timbre: 0.5)
    }
}
