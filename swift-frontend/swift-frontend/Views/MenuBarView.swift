//
//  MenuBarView.swift
//  swift-frontend
//
//  Created by Melih Özdemir on 31.08.2025.
//

import SwiftUI

struct MenuBarView: View {
    @StateObject private var viewModel = MenuBarViewModel()
    @State private var scanTask: Task<Void, Never>?
    @State private var showSettings = false
    
    // Design System Colors
    private struct Colors {
        static let primary = Color(red: 0.09, green: 0.11, blue: 0.15)
        static let secondary = Color(red: 0.13, green: 0.16, blue: 0.21)
        static let accent = Color(red: 0.27, green: 0.54, blue: 1.0)
        static let success = Color(red: 0.2, green: 0.78, blue: 0.35)
        static let warning = Color(red: 1.0, green: 0.58, blue: 0.0)
        static let danger = Color(red: 1.0, green: 0.23, blue: 0.19)
        static let textPrimary = Color.primary
        static let textSecondary = Color.secondary
        static let surface = Color(NSColor.controlBackgroundColor)
        static let background = Color(NSColor.windowBackgroundColor)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Modern Header with gradient
            VStack(spacing: 8) {
                HStack(spacing: 10) {
                    // App icon with gradient
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Colors.accent, Colors.accent.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 24, height: 24)
                        
                        Image(systemName: "cpu.fill")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Port Monitor")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Colors.textPrimary)
                        
                        HStack(spacing: 4) {
                            Circle()
                                .fill(viewModel.processes.isEmpty ? Colors.textSecondary : Colors.success)
                                .frame(width: 6, height: 6)
                            
                            Text("\(viewModel.processes.count) active")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(Colors.textSecondary)
                        }
                    }
                    
                    Spacer()
                    
                    // Action buttons
                    HStack(spacing: 6) {
                        // Refresh button
                        Button(action: {
                            refreshProcesses()
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Colors.surface)
                                    .frame(width: 24, height: 24)
                                
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(Colors.accent)
                                    .frame(width: 24, height: 24) // Icon'u circle ile aynı boyutta frame ver
                                    .rotationEffect(.degrees(viewModel.isScanning ? 360 : 0))
                                    .animation(
                                        viewModel.isScanning ? 
                                        .linear(duration: 1).repeatForever(autoreverses: false) : 
                                        .default,
                                        value: viewModel.isScanning
                                    )
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(viewModel.isScanning)
                        
                        // Settings button
                        Button(action: {
                            showSettings = true
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Colors.surface)
                                    .frame(width: 24, height: 24)
                                
                                Image(systemName: "gear")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(Colors.textSecondary)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                
                // Scanning indicator
                if viewModel.isScanning {
                    HStack(spacing: 6) {
                        ProgressView()
                            .scaleEffect(0.6)
                            .tint(Colors.accent)
                        
                        Text("Scanning ports...")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Colors.textSecondary)
                    }
                    .padding(.horizontal, 16)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(.bottom, 8)
            .background(
                LinearGradient(
                    colors: [Colors.background, Colors.background.opacity(0.98)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            
            
            // Elegant divider
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Colors.textSecondary.opacity(0.3), Colors.textSecondary.opacity(0.1)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1)
                .padding(.horizontal, 16)
            
            // Process List with enhanced design
            ScrollView {
                LazyVStack(spacing: 6) {
                    if viewModel.processes.isEmpty && !viewModel.isScanning {
                        // Empty state with better design
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Colors.success.opacity(0.1))
                                    .frame(width: 48, height: 48)
                                
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundColor(Colors.success)
                            }
                            
                            VStack(spacing: 4) {
                                Text("All Clear!")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(Colors.textPrimary)
                                
                                Text("No processes running on monitored ports")
                                    .font(.system(size: 10))
                                    .foregroundColor(Colors.textSecondary)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding(.vertical, 24)
                        .frame(maxWidth: .infinity)
                    } else {
                        ForEach(viewModel.processes, id: \.id) { process in
                            ProcessRowView(
                                process: process,
                                onKill: {
                                    killProcess(process)
                                }
                            )
                            .padding(.horizontal, 12)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            .frame(height: 160)
            
            
            // Elegant divider
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Colors.textSecondary.opacity(0.3), Colors.textSecondary.opacity(0.1)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1)
                .padding(.horizontal, 16)
            
            // Modern Footer
            HStack(spacing: 12) {
                Button("Settings") {
                    showSettings = true
                }
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Colors.accent)
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                Button("Quit") {
                    NSApp.terminate(nil)
                }
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Colors.danger)
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Colors.background.opacity(0.5))
        }
        .frame(width: 300, height: 280)
        .background(Colors.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
        .onAppear {
            refreshProcesses()
        }
        .onDisappear {
            scanTask?.cancel()
            scanTask = nil
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
    
    // MARK: - Private Methods
    
    private func refreshProcesses() {
        scanTask?.cancel()
        scanTask = Task { [weak viewModel] in
            await viewModel?.scanProcesses()
        }
    }
    
    private func killProcess(_ process: ProcessInfo) {
        Task { [weak viewModel] in
            await viewModel?.killProcess(process)
            await viewModel?.scanProcesses()
        }
    }
}

struct ProcessRowView: View {
    let process: ProcessInfo
    let onKill: () -> Void
    @State private var isHovered = false
    @State private var killTask: Task<Void, Never>?
    
    // Design System Colors (reused from parent)
    private struct Colors {
        static let primary = Color(red: 0.09, green: 0.11, blue: 0.15)
        static let secondary = Color(red: 0.13, green: 0.16, blue: 0.21)
        static let accent = Color(red: 0.27, green: 0.54, blue: 1.0)
        static let success = Color(red: 0.2, green: 0.78, blue: 0.35)
        static let warning = Color(red: 1.0, green: 0.58, blue: 0.0)
        static let danger = Color(red: 1.0, green: 0.23, blue: 0.19)
        static let textPrimary = Color.primary
        static let textSecondary = Color.secondary
        static let surface = Color(NSColor.controlBackgroundColor)
        static let background = Color(NSColor.windowBackgroundColor)
    }
    
    var body: some View {
        HStack(spacing: 10) {
            // Port badge with modern design
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [Colors.accent, Colors.accent.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 28)
                
                Text("\(process.port)")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
            }
            
            // Process info
            VStack(alignment: .leading, spacing: 2) {
                Text(process.name)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Colors.textPrimary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                HStack(spacing: 4) {
                    Text("PID")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(Colors.textSecondary)
                    
                    Text("\(process.pid)")
                        .font(.system(size: 9, weight: .semibold, design: .monospaced))
                        .foregroundColor(Colors.textSecondary)
                }
            }
            
            Spacer()
            
            // Kill button with enhanced design
            Button(action: handleKillAction) {
                ZStack {
                    Circle()
                        .fill(
                            isHovered ? 
                            LinearGradient(
                                colors: [Colors.danger, Colors.danger.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [Colors.danger.opacity(0.7), Colors.danger.opacity(0.5)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 24, height: 24)
                    
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(PlainButtonStyle())
            .scaleEffect(isHovered ? 1.1 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isHovered)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    isHovered ? 
                    Colors.surface.opacity(0.8) : 
                    Colors.surface.opacity(0.3)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(
                    isHovered ? Colors.accent.opacity(0.3) : Color.clear,
                    lineWidth: 1
                )
        )
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
        .onDisappear {
            killTask?.cancel()
            killTask = nil
        }
    }
    
    private func handleKillAction() {
        killTask?.cancel()
        killTask = Task {
            onKill()
        }
    }
}

// MARK: - Extensions

extension Animation {
    static func repeatWhileTrue(_ condition: Bool) -> Animation {
        condition ? .linear(duration: 1).repeatForever(autoreverses: false) : .default
    }
}

#Preview {
    MenuBarView()
        .frame(width: 300, height: 280)
        .background(Color(NSColor.windowBackgroundColor))
}
