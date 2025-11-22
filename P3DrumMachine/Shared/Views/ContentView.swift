//
//  ContentView.swift
//  P3DrumMachine
//
//  Created on 2025-11-22.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var sessionViewModel: SessionViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("P3 Drum Machine")
                .font(.system(size: 48, weight: .bold, design: .monospaced))
                .foregroundColor(.white)

            Text("SwiftUI Multiplatform")
                .font(.system(size: 24, weight: .light, design: .monospaced))
                .foregroundColor(.gray)

            #if os(macOS)
            Text("Running on macOS")
                .font(.system(size: 16, design: .monospaced))
                .foregroundColor(.white.opacity(0.7))
            #else
            Text("Running on iPadOS")
                .font(.system(size: 16, design: .monospaced))
                .foregroundColor(.white.opacity(0.7))
            #endif

            Text("✅ Project scaffold complete")
                .font(.system(size: 14, design: .monospaced))
                .foregroundColor(.green)
                .padding(.top, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}

#Preview {
    ContentView()
        .environmentObject(SessionViewModel())
}
