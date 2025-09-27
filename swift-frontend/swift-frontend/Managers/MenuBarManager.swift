//
//  MenuBarManager.swift
//  swift-frontend
//
//  Created by Melih Özdemir on 31.08.2025.
//

import AppKit
import SwiftUI

class MenuBarManager: ObservableObject {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private weak var viewModel: MenuBarViewModel?  // Weak reference to prevent retain cycle

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
            setupMenuBarIcon(button)
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
            let button = statusItem?.button
        else {
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
                let button = self.statusItem?.button
            else { return }

            // Try to load custom icon first, then SF Symbol
            if let customImage = self.loadCustomMenuBarIcon() {
                button.image = customImage
                button.title = ""  // Clear any existing title
            } else if let image = NSImage(
                systemSymbolName: systemName, accessibilityDescription: title ?? "Port Kill Monitor"
            ) {
                image.isTemplate = true
                image.size = NSSize(width: 16, height: 16)
                button.image = image
                button.title = ""  // Clear any existing title
            } else {
                // Ultimate fallback to emoji
                button.title = "⚡"
                button.image = nil
            }

            if let title = title {
                button.toolTip = title
            }
        }
    }

    func updateStatusWithProcessCount(_ count: Int) {
        let iconName = count > 0 ? "bolt.fill" : "bolt"
        let tooltip =
            count > 0
            ? "Port Kill Monitor - \(count) active processes"
            : "Port Kill Monitor - No active processes"
        updateStatusIcon(iconName, title: tooltip)
    }

    // MARK: - Icon Configuration

    private func setupMenuBarIcon(_ button: NSStatusBarButton) {
        // Try to load custom icon first
        if let customImage = loadCustomMenuBarIcon() {
            button.image = customImage
            button.title = ""
        } else {
            // Use SF Symbol with better default icon
            if let image = NSImage(
                systemSymbolName: "bolt.fill", accessibilityDescription: "Port Kill Monitor")
            {
                image.isTemplate = true
                image.size = NSSize(width: 16, height: 16)
                button.image = image
                button.title = ""
            } else {
                // Ultimate fallback
                button.title = "⚡"
                button.image = nil
                button.font = NSFont.systemFont(ofSize: 14)
            }
        }

        // Set action and tooltip
        button.action = #selector(togglePopover)
        button.target = self
        button.toolTip = "Port Kill Monitor - Click to open"

        print("Menu bar icon configured successfully")
    }

    private func loadCustomMenuBarIcon() -> NSImage? {
        // Method 1: Try to load from Assets catalog with correct name
        if let image = NSImage(named: "MenuBarIcon") {
            print("✓ Loaded MenuBarIcon from Assets catalog")
            image.isTemplate = false  // Don't use template mode to preserve colors
            image.size = NSSize(width: 16, height: 16)
            return image
        }

        // Method 2: Try to load 16x16 PNG directly from Assets catalog
        if let image = NSImage(named: "MenuBarIcon_16x16") {
            print("✓ Loaded MenuBarIcon_16x16 from Assets catalog")
            image.isTemplate = false  // Don't use template mode to preserve colors
            image.size = NSSize(width: 16, height: 16)
            return image
        }

        // Method 3: Try to load from app bundle Resources (compiled PNG)
        if let bundlePath = Bundle.main.resourcePath {
            let possiblePaths = [
                "\(bundlePath)/MenuBarIcon_16x16.png",
                "\(bundlePath)/MenuBarIcon.png",
            ]

            for path in possiblePaths {
                if let customImage = NSImage(contentsOfFile: path) {
                    print("✓ Loaded custom icon from: \(path)")
                    customImage.isTemplate = true
                    customImage.size = NSSize(width: 16, height: 16)
                    return customImage
                }
            }
        }

        // Method 4: Try to use AppIcon as menu bar icon (scaled down)
        if let appIcon = NSImage(named: "AppIcon") {
            print("✓ Using AppIcon as menu bar icon (scaled)")
            let menuBarIcon = NSImage(size: NSSize(width: 16, height: 16))
            menuBarIcon.lockFocus()
            appIcon.draw(in: NSRect(x: 0, y: 0, width: 16, height: 16))
            menuBarIcon.unlockFocus()
            menuBarIcon.isTemplate = true
            return menuBarIcon
        }

        print("⚠️ Could not load any custom menu bar icon")
        return nil
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
