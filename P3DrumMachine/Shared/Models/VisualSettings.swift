//
//  VisualSettings.swift
//  P3DrumMachine
//
//  Created on 2025-11-22.
//  Step 1: Shared Models & App State
//

import Foundation
import SwiftUI

/// Visual customization settings for the session
struct VisualSettings: Codable {
    var tintColorHex: String // Hex color string (e.g., "#FFFFFF")
    var brightness: Double // 0.0 to 1.0
    var artworkURL: URL? // Background artwork
    var artworkPrompt: String? // AI prompt for artwork generation (stub)
    var stylePreset: StylePreset

    init(
        tintColorHex: String = "#FFFFFF",
        brightness: Double = 1.0,
        artworkURL: URL? = nil,
        artworkPrompt: String? = nil,
        stylePreset: StylePreset = .default
    ) {
        self.tintColorHex = tintColorHex
        self.brightness = brightness
        self.artworkURL = artworkURL
        self.artworkPrompt = artworkPrompt
        self.stylePreset = stylePreset
    }

    // MARK: - Computed Properties

    var tintColor: Color {
        Color(hex: tintColorHex) ?? .white
    }

    // MARK: - Mutations

    mutating func setTintColor(_ color: Color) {
        self.tintColorHex = color.toHex() ?? "#FFFFFF"
    }

    mutating func adjustBrightness(_ delta: Double) {
        brightness = min(max(brightness + delta, 0.0), 1.0)
    }
}

/// Style presets for visual theming
enum StylePreset: String, Codable, CaseIterable, Identifiable {
    case `default` = "Default"
    case minimal = "Minimal"
    case neon = "Neon"
    case retro = "Retro"
    case cyber = "Cyber"

    var id: String { rawValue }

    var description: String {
        switch self {
        case .default: return "Clean monochromatic design"
        case .minimal: return "Ultra-minimal interface"
        case .neon: return "Bright neon accents"
        case .retro: return "Vintage aesthetic"
        case .cyber: return "Cyberpunk vibes"
        }
    }

    // Style-specific parameters
    var primaryColor: Color {
        switch self {
        case .default: return .white
        case .minimal: return .gray
        case .neon: return Color(hex: "#00FF00") ?? .green
        case .retro: return Color(hex: "#FFA500") ?? .orange
        case .cyber: return Color(hex: "#00FFFF") ?? .cyan
        }
    }

    var backgroundColor: Color {
        .black
    }

    var accentOpacity: Double {
        switch self {
        case .default: return 1.0
        case .minimal: return 0.6
        case .neon: return 1.0
        case .retro: return 0.8
        case .cyber: return 0.9
        }
    }
}

// MARK: - Color Extensions

extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    func toHex() -> String? {
        #if os(macOS)
        guard let components = NSColor(self).cgColor.components else { return nil }
        #else
        guard let components = UIColor(self).cgColor.components else { return nil }
        #endif

        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])

        return String(format: "#%02lX%02lX%02lX",
                     lroundf(r * 255),
                     lroundf(g * 255),
                     lroundf(b * 255))
    }
}
