//
//  KillPortApp.swift
//  kill-port
//
//  Created by Melih Özdemir on 31.08.2025.
//

import SwiftUI

@main
struct KillPortApp: App {
    @StateObject private var menuBarManager = MenuBarManager()
    @State private var isTerminating = false
    
    init() {
        // Hide dock icon and menu bar for menu bar-only app
        DispatchQueue.main.async {
            NSApp.setActivationPolicy(.accessory)
        }
        
        // Handle app termination properly
        NotificationCenter.default.addObserver(
            forName: NSApplication.willTerminateNotification,
            object: nil,
            queue: .main
        ) { [isTerminating] _ in
            guard !isTerminating else { return }
            // Cleanup happens automatically through deinit methods
            print("App terminating - cleanup initiated")
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
