//
//  swift_frontendApp.swift
//  swift-frontend
//
//  Created by Melih Özdemir on 31.08.2025.
//

import SwiftUI

@main
struct swift_frontendApp: App {
    @StateObject private var menuBarManager = MenuBarManager()
    
    init() {
        // Hide dock icon and menu bar for menu bar-only app
        DispatchQueue.main.async {
            NSApp.setActivationPolicy(.accessory)
        }
    }
    
    var body: some Scene {
        // Keep a minimal window to prevent the app from terminating
        WindowGroup {
            ContentView()
                .frame(width: 1, height: 1)
                .opacity(0)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 1, height: 1)
        .windowLevel(.floating)
    }
}
