//
//  P3DrumMachineApp.swift
//  P3DrumMachine
//
//  Created on 2025-11-22.
//

import SwiftUI

@main
struct P3DrumMachineApp: App {
    @StateObject private var sessionViewModel = SessionViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sessionViewModel)
        }
        #if os(macOS)
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
        #endif
    }
}
