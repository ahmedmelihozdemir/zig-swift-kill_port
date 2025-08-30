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
    
    var body: some Scene {
        // Hide the main window - we only want menu bar functionality
        Settings {
            EmptyView()
        }
    }
}
