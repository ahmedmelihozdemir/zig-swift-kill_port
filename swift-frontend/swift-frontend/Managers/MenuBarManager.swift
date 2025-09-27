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
        print("MenuBarManager initializing...")
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { 
                print("Error: MenuBarManager self is nil during setup")
                return 
            }
            
            print("Setting up menu bar and popover...")
            self.setupMenuBar()
            self.setupPopover()
            
            print("MenuBarManager setup completed successfully")
        }
    }

    private func setupMenuBar() {
        print("Setting up menu bar...")

        // Create status item with fixed length to ensure visibility
        statusItem = NSStatusBar.system.statusItem(withLength: 28.0)

        guard let statusItem = statusItem else {
            print("Error: Could not create status item")
            return
        }

        print("Status item created successfully")

        // Setup button
        if let button = statusItem.button {
            setupMenuBarIcon(button)
            // Force the status item to be visible
            statusItem.isVisible = true
            print("Status item visibility set to: \(statusItem.isVisible)")
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

        // Create MenuBarView directly - SwiftUI will handle the view model
        let menuBarView = MenuBarView()
        let hostingController = NSHostingController(rootView: menuBarView)
        
        // Set content view controller
        popover.contentViewController = hostingController

        print("Popover configured successfully")
        print("MenuBarView loaded into popover")
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
        // Use network/connection icons that change based on activity
        let iconName = count > 0 ? "antenna.radiowaves.left.and.right" : "network"
        let tooltip =
            count > 0
            ? "Port Kill Monitor - \(count) active processes"
            : "Port Kill Monitor - No active processes"
        updateStatusIcon(iconName, title: tooltip)
    }

    // MARK: - Icon Configuration

    private func setupMenuBarIcon(_ button: NSStatusBarButton) {
        print("Setting up menu bar icon...")

        // Clear any existing content first
        button.image = nil
        button.title = ""

        // Try network/port related icons first - perfect for our port kill app
        if let image = NSImage(
            systemSymbolName: "network", accessibilityDescription: "Port Kill Monitor")
        {
            image.isTemplate = true
            image.size = NSSize(width: 16, height: 16)
            button.image = image
            button.title = ""
            print("✅ SF Symbol network icon set successfully")
            print("✅ Image properties - isTemplate: \(image.isTemplate), size: \(image.size)")
        } else if let image = NSImage(
            systemSymbolName: "point.3.connected.trianglepath.dotted",
            accessibilityDescription: "Port Kill Monitor")
        {
            image.isTemplate = true
            image.size = NSSize(width: 16, height: 16)
            button.image = image
            button.title = ""
            print("✅ SF Symbol connected network icon set successfully")
        } else if let image = NSImage(
            systemSymbolName: "cable.connector", accessibilityDescription: "Port Kill Monitor")
        {
            image.isTemplate = true
            image.size = NSSize(width: 16, height: 16)
            button.image = image
            button.title = ""
            print("✅ SF Symbol cable connector icon set successfully")
        } else if let image = NSImage(
            systemSymbolName: "externaldrive.connected.to.line.below",
            accessibilityDescription: "Port Kill Monitor")
        {
            image.isTemplate = true
            image.size = NSSize(width: 16, height: 16)
            button.image = image
            button.title = ""
            print("✅ SF Symbol external drive connected icon set successfully")
        } else if let image = NSImage(
            systemSymbolName: "bolt.horizontal.fill", accessibilityDescription: "Port Kill Monitor")
        {
            image.isTemplate = true
            image.size = NSSize(width: 16, height: 16)
            button.image = image
            button.title = ""
            print("✅ SF Symbol horizontal bolt icon set successfully")
        } else if let image = NSImage(
            systemSymbolName: "antenna.radiowaves.left.and.right",
            accessibilityDescription: "Port Kill Monitor")
        {
            image.isTemplate = true
            image.size = NSSize(width: 16, height: 16)
            button.image = image
            button.title = ""
            print("✅ SF Symbol antenna radiowaves icon set successfully")
        } else {
            // Ultimate fallback - port/connection related
            button.title = "◉"  // Circle with dot - represents port/connection
            button.image = nil
            button.font = NSFont.systemFont(ofSize: 14, weight: .medium)
            print("⚠️ Using connection symbol fallback icon")
        }

        // Set action and tooltip
        button.action = #selector(togglePopover)
        button.target = self
        button.toolTip = "Port Kill Monitor - Click to open"

        // Ensure button is enabled and visible
        button.appearsDisabled = false

        print("Menu bar icon configured successfully")
        print("Final button title: '\(button.title)'")
        print("Final button image: \(button.image?.description ?? "nil")")
        print("Final button image isTemplate: \(button.image?.isTemplate ?? false)")

        // Force a display update
        button.needsDisplay = true
        button.display()
    }

    private func loadCustomMenuBarIcon() -> NSImage? {
        // Method 1: Try to load from Assets catalog with correct name
        if let originalImage = NSImage(named: "MenuBarIcon") {
            print("✓ Loaded MenuBarIcon from Assets catalog")

            // Create a properly sized copy for menu bar
            let menuBarSize = NSSize(width: 16, height: 16)
            let resizedImage = NSImage(size: menuBarSize)

            resizedImage.lockFocus()
            originalImage.draw(
                in: NSRect(origin: .zero, size: menuBarSize),
                from: NSRect(origin: .zero, size: originalImage.size),
                operation: .sourceOver,
                fraction: 1.0)
            resizedImage.unlockFocus()

            // Use template mode for proper macOS menu bar appearance
            resizedImage.isTemplate = true

            print("✓ MenuBarIcon processed with template mode - size: \(resizedImage.size)")
            return resizedImage
        }

        // Method 2: Try to load 16x16 PNG directly from Assets catalog
        if let originalImage = NSImage(named: "MenuBarIcon_16x16") {
            print("✓ Loaded MenuBarIcon_16x16 from Assets catalog")

            // Create a copy and set proper template mode
            let menuBarImage = NSImage(size: NSSize(width: 16, height: 16))
            menuBarImage.lockFocus()
            originalImage.draw(in: NSRect(x: 0, y: 0, width: 16, height: 16))
            menuBarImage.unlockFocus()

            menuBarImage.isTemplate = true
            return menuBarImage
        }

        // Method 3: Try to load from app bundle Resources (compiled PNG)
        if let bundlePath = Bundle.main.resourcePath {
            let possiblePaths = [
                "\(bundlePath)/MenuBarIcon_16x16.png",
                "\(bundlePath)/MenuBarIcon.png",
            ]

            for path in possiblePaths {
                if let originalImage = NSImage(contentsOfFile: path) {
                    print("✓ Loaded custom icon from: \(path)")

                    let menuBarImage = NSImage(size: NSSize(width: 16, height: 16))
                    menuBarImage.lockFocus()
                    originalImage.draw(in: NSRect(x: 0, y: 0, width: 16, height: 16))
                    menuBarImage.unlockFocus()

                    menuBarImage.isTemplate = true
                    return menuBarImage
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
