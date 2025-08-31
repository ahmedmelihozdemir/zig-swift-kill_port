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
    private var viewModel: MenuBarViewModel?
    
    init() {
        DispatchQueue.main.async {
            self.setupMenuBar()
            self.setupPopover()
        }
    }
    
    private func setupMenuBar() {
        print("Setting up menu bar...")
        
        // Create status item with fixed length
        statusItem = NSStatusBar.system.statusItem(withLength: 28)
        
        guard let statusItem = statusItem else { 
            print("Error: Could not create status item")
            return 
        }
        
        print("Status item created successfully")
        
        // Setup button
        if let button = statusItem.button {
            // Use a simple text icon that's always visible
            button.title = "⚡️"
            button.font = NSFont.systemFont(ofSize: 18)
            
            // Set action
            button.action = #selector(togglePopover)
            button.target = self
            button.toolTip = "Port Monitor - Click to open"
            
            print("Button configured successfully with title: ⚡️")
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
        
        popover.contentSize = NSSize(width: 280, height: 250)
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
            guard let button = self?.statusItem?.button else { return }
            
            button.image = NSImage(systemSymbolName: systemName, accessibilityDescription: title ?? "Port Kill")
            button.image?.isTemplate = true
            
            if let title = title {
                button.toolTip = title
            }
        }
    }
    
    deinit {
        if let statusItem = statusItem {
            NSStatusBar.system.removeStatusItem(statusItem)
        }
    }
}