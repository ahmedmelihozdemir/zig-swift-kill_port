import SwiftUI

@main
struct swift_frontendApp: App {
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
        // Empty scene - menu bar only app
        Settings {
            EmptyView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 0, height: 0)
    }
}
