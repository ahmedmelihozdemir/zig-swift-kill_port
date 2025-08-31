//
//  MenuBarView.swift
//  swift-frontend
//
//  Created by Melih Özdemir on 31.08.2025.
//

import SwiftUI

struct MenuBarView: View {
    @StateObject private var viewModel = MenuBarViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Modern Header with gradient
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: "bolt.circle.fill")
                        .font(.title2)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Port Monitor")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("Kill unwanted processes")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Refresh Button
                    Button(action: {
                        viewModel.refreshProcesses()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(width: 28, height: 28)
                            .background(Color(.controlBackgroundColor))
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color(.separatorColor), lineWidth: 0.5)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(viewModel.isScanning)
                    .rotationEffect(.degrees(viewModel.isScanning ? 360 : 0))
                    .animation(.linear(duration: 1).repeatWhileTrue(viewModel.isScanning), value: viewModel.isScanning)
                }
                
                // Status Card
                HStack(spacing: 8) {
                    if viewModel.isScanning {
                        ProgressView()
                            .scaleEffect(0.7)
                            .controlSize(.mini)
                    } else {
                        Image(systemName: viewModel.processes.isEmpty ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                            .foregroundColor(viewModel.processes.isEmpty ? .green : .orange)
                            .font(.system(size: 12))
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(viewModel.statusInfo.text)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Text(viewModel.statusInfo.tooltip)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.controlBackgroundColor).opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)
            
            // Elegant separator
            Rectangle()
                .fill(LinearGradient(
                    colors: [.clear, Color(.separatorColor), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                ))
                .frame(height: 1)
                .padding(.horizontal, 16)
            
            // Process List with improved design
            if viewModel.processes.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 32))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.green, .mint],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    VStack(spacing: 4) {
                        Text("All Clear! 🎉")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("No active processes found on monitored ports")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            } else {
                VStack(spacing: 0) {
                    // Process count header
                    HStack {
                        Text("\(viewModel.processes.count) Active Process\(viewModel.processes.count > 1 ? "es" : "")")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("Tap ⊗ to kill")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                    
                    // Process list
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 8) {
                            ForEach(viewModel.processes) { process in
                                ProcessRowView(
                                    process: process,
                                    isKilling: viewModel.isKilling,
                                    onKill: {
                                        viewModel.killProcess(process)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .frame(maxHeight: 280)
                    
                    // Kill All Button with improved design
                    VStack(spacing: 0) {
                        Rectangle()
                            .fill(Color(.separatorColor))
                            .frame(height: 1)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        
                        Button(action: {
                            viewModel.killAllProcesses()
                        }) {
                            HStack(spacing: 8) {
                                if viewModel.isKilling {
                                    ProgressView()
                                        .scaleEffect(0.7)
                                        .controlSize(.mini)
                                        .tint(.white)
                                } else {
                                    Image(systemName: "trash.fill")
                                        .font(.system(size: 14, weight: .medium))
                                }
                                
                                Text("Kill All Processes")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                LinearGradient(
                                    colors: [.red, .pink],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .shadow(color: .red.opacity(0.3), radius: 4, x: 0, y: 2)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(viewModel.processes.isEmpty || viewModel.isKilling)
                        .opacity(viewModel.processes.isEmpty || viewModel.isKilling ? 0.6 : 1.0)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                    }
                }
            }
            
            // Modern Footer with organized menu
            VStack(spacing: 0) {
                Rectangle()
                    .fill(LinearGradient(
                        colors: [.clear, Color(.separatorColor), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .frame(height: 1)
                    .padding(.horizontal, 16)
                
                HStack(spacing: 16) {
                    // Settings Menu
                    Menu {
                        Button(action: {
                            openSettingsWindow()
                        }) {
                            Label("Preferences", systemImage: "gear")
                        }
                        
                        Button(action: {
                            openAboutWindow()
                        }) {
                            Label("About Port Monitor", systemImage: "info.circle")
                        }
                        
                        Divider()
                        
                        Button(action: {
                            openHelpURL()
                        }) {
                            Label("Help & Documentation", systemImage: "questionmark.circle")
                        }
                        
                        Button(action: {
                            openGitHubURL()
                        }) {
                            Label("GitHub Repository", systemImage: "link")
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "ellipsis.circle")
                                .font(.system(size: 14))
                            Text("Menu")
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                    }
                    .menuStyle(.borderlessButton)
                    
                    Spacer()
                    
                    // Auto-refresh toggle
                    Button(action: {
                        // TODO: Toggle auto refresh
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "timer")
                                .font(.system(size: 14))
                            Text("Auto")
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Quit button with confirmation
                    Button(action: {
                        let alert = NSAlert()
                        alert.messageText = "Quit Port Monitor?"
                        alert.informativeText = "This will stop monitoring ports and close the application."
                        alert.alertStyle = .warning
                        alert.addButton(withTitle: "Quit")
                        alert.addButton(withTitle: "Cancel")
                        
                        if alert.runModal() == .alertFirstButtonReturn {
                            NSApplication.shared.terminate(nil)
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "power")
                                .font(.system(size: 14))
                            Text("Quit")
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .frame(width: 340)
        .background(
            Color(.windowBackgroundColor)
                .overlay(
                    // Subtle gradient overlay
                    LinearGradient(
                        colors: [
                            Color(.controlBackgroundColor).opacity(0.1),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        )
        .alert("Error", isPresented: $viewModel.showingError) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
    
    // MARK: - Helper Functions
    private func openSettingsWindow() {
        let settingsView = SettingsView()
        let hostingController = NSHostingController(rootView: settingsView)
        
        let window = NSWindow(contentViewController: hostingController)
        window.title = "Port Monitor Settings"
        window.styleMask = [.titled, .closable]
        window.isReleasedWhenClosed = false
        window.center()
        window.makeKeyAndOrderFront(nil)
    }
    
    private func openAboutWindow() {
        let alert = NSAlert()
        alert.messageText = "Port Monitor"
        alert.informativeText = """
        Version 1.0.0
        
        A beautiful macOS menu bar application for monitoring and managing processes on development ports.
        
        Created by Ahmed Melih Özdemir
        © 2025 All rights reserved.
        
        Built with Swift & Zig
        """
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Visit GitHub")
        
        let response = alert.runModal()
        if response == .alertSecondButtonReturn {
            openGitHubURL()
        }
    }
    
    private func openHelpURL() {
        if let url = URL(string: "https://github.com/ahmedmelihozdemir/zig-swift-kill_port/blob/main/USER_GUIDE.md") {
            NSWorkspace.shared.open(url)
        }
    }
    
    private func openGitHubURL() {
        if let url = URL(string: "https://github.com/ahmedmelihozdemir/zig-swift-kill_port") {
            NSWorkspace.shared.open(url)
        }
    }
}

struct ProcessRowView: View {
    let process: ProcessInfo
    let isKilling: Bool
    let onKill: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Modern Port Badge
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue, .cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 36, height: 36)
                    .shadow(color: .blue.opacity(0.3), radius: 4, x: 0, y: 2)
                
                VStack(spacing: 0) {
                    Text("\(process.port)")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    
                    Text("PORT")
                        .font(.system(size: 6, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            // Process Information
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(process.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // PID Badge
                    Text("PID \(process.pid)")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(.quaternaryLabelColor))
                        .clipShape(Capsule())
                }
                
                Text(process.command)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            
            // Modern Kill Button
            Button(action: onKill) {
                ZStack {
                    Circle()
                        .fill(Color.red.opacity(0.1))
                        .frame(width: 28, height: 28)
                        .overlay(
                            Circle()
                                .stroke(Color.red.opacity(0.3), lineWidth: 1)
                        )
                    
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.red)
                }
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(isKilling)
            .opacity(isKilling ? 0.5 : 1.0)
            .scaleEffect(isKilling ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isKilling)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.controlBackgroundColor))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.separatorColor).opacity(0.5), lineWidth: 0.5)
        )
    }
}

#Preview {
    MenuBarView()
}

// MARK: - Animation Extensions
extension Animation {
    func repeatWhileTrue(_ condition: Bool) -> Animation {
        return condition ? self.repeatForever(autoreverses: false) : self
    }
}
