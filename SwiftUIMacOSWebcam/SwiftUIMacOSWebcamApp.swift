//
        //
    //  Project: SwiftUIMacOSWebcam
    //  File: SwiftUIMacOSWebcamApp.swift
    //  Created by Noah Carpenter 
    //
    //  📺 YouTube: Noah Does Coding
    //  https://www.youtube.com/@NoahDoesCoding
    //  Like and Subscribe for coding tutorials and fun! 💻✨
    //  Dream Big. Code Bigger 🚀
    //

    

import SwiftUI

// Main app entry point
@main
struct SwiftUIMacOSWebcamApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // Hide the title bar for a cleaner look
        .windowStyle(.hiddenTitleBar)
        // Set default window size
        .defaultSize(width: 800, height: 600)
    }
}
