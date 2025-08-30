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
        setupMenuBar()
    }
    
    private func setupMenuBar() {
        // Create status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        guard let statusItem = statusItem else { return }
        
        // Setup button
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "bolt.circle", accessibilityDescription: "Port Kill")
            button.image?.isTemplate = true
            button.action = #selector(togglePopover)
            button.target = self
        }
        
        // Create popover
        setupPopover()
    }
    
    private func setupPopover() {
        popover = NSPopover()
        guard let popover = popover else { return }
        
        popover.contentSize = NSSize(width: 320, height: 400)
        popover.behavior = .transient
        popover.animates = true
        
        // Create hosting view
        let menuBarView = MenuBarView()
        popover.contentViewController = NSHostingController(rootView: menuBarView)
    }
    
    @objc private func togglePopover() {
        guard let popover = popover,
              let button = statusItem?.button else { return }
        
        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            
            // Activate app to ensure popover is focused
            NSApplication.shared.activate(ignoringOtherApps: true)
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
