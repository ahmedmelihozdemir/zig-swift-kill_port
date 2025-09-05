//
//  MenuBarManager.swift
//  swift-frontend
//
//  Created by Melih Özdemir on 31.08.2025.
//

import SwiftUI
import AppKit

class MenuBarManager: ObservableObject {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private weak var viewModel: MenuBarViewModel? // Weak reference to prevent retain cycle
    
    init() {
        DispatchQueue.main.async { [weak self] in
            self?.setupMenuBar()
            self?.setupPopover()
        }
    }
    
    private func setupMenuBar() {
        print("Setting up menu bar...")
        
        // Create status item with variable length for better integration
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        guard let statusItem = statusItem else { 
            print("Error: Could not create status item")
            return 
        }
        
        print("Status item created successfully")
        
        // Setup button
        if let button = statusItem.button {
            // Use SF Symbol for process monitoring with proper sizing
            if let image = NSImage(systemSymbolName: "cpu.fill", accessibilityDescription: "Swift Frontend") {
                image.isTemplate = true
                // Set proper size for menu bar - smaller and more native
                image.size = NSSize(width: 16, height: 16)
                button.image = image
            } else {
                // Fallback to text icon
                button.title = "⚡️"
                button.font = NSFont.systemFont(ofSize: 14)
            }
            
            // Set action
            button.action = #selector(togglePopover)
            button.target = self
            button.toolTip = "Swift Frontend - Click to open"
            
            print("Button configured successfully with process icon")
        } else {
            print("Error: Could not access status item button")
        }
    }
    
    private func setupPopover() {
        print("Setting up popover...")
        
        popover = NSPopover()
        guard let popover = popover else { 
            print("Error: Could not create popover")
            return 
        }
        
        popover.contentSize = NSSize(width: 300, height: 280)
        popover.behavior = .transient
        popover.animates = true
        
        // Create hosting view
        let menuBarView = MenuBarView()
        let hostingController = NSHostingController(rootView: menuBarView)
        popover.contentViewController = hostingController
        
        print("Popover configured successfully")
    }
    
    @objc private func togglePopover() {
        guard let popover = popover,
              let button = statusItem?.button else { 
            print("Error: Popover or button not available")
            return 
        }
        
        print("Toggle popover called - Current state: \(popover.isShown)")
        
        if popover.isShown {
            popover.performClose(nil)
        } else {
            // Calculate position
            let buttonRect = button.bounds
            print("Showing popover at button bounds: \(buttonRect)")
            
            popover.show(relativeTo: buttonRect, of: button, preferredEdge: .minY)
            
            // Activate app to ensure popover is focused
            NSApplication.shared.activate(ignoringOtherApps: true)
            
            // Make sure the popover window is key
            popover.contentViewController?.view.window?.makeKey()
        }
    }
    
    func updateStatusIcon(_ systemName: String, title: String? = nil) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  let button = self.statusItem?.button else { return }
            
            if let image = NSImage(systemSymbolName: systemName, accessibilityDescription: title ?? "Swift Frontend") {
                image.isTemplate = true
                image.size = NSSize(width: 16, height: 16)
                button.image = image
                button.title = "" // Clear any existing title
            }
            
            if let title = title {
                button.toolTip = title
            }
        }
    }
    
    func updateStatusWithProcessCount(_ count: Int) {
        let iconName = count > 0 ? "cpu.fill" : "cpu"
        let tooltip = count > 0 ? "Swift Frontend - \(count) active processes" : "Swift Frontend - No active processes"
        updateStatusIcon(iconName, title: tooltip)
    }
    
    deinit {
        print("MenuBarManager deinit called")
        
        // Clean up popover
        popover?.close()
        popover = nil
        
        // Remove status item
        if let statusItem = statusItem {
            NSStatusBar.system.removeStatusItem(statusItem)
            self.statusItem = nil
        }
        
        viewModel = nil
    }
}