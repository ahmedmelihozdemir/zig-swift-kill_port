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
    struct Colors {
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
                                    .rotationEffect(.degrees(viewModel.isScanning ? 360 : 0))
                                    .animation(
                                        viewModel.isScanning ? 
                                        .linear(duration: 1).repeatForever(autoreverses: false) : 
                                        .default,
                                        value: viewModel.isScanning
                                    )
                            }
                            .clipShape(Circle())
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
                                
                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(Colors.textSecondary)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Quit button
                        Button(action: {
                            NSApplication.shared.terminate(nil)
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Colors.surface)
                                    .frame(width: 24, height: 24)
                                
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(Colors.danger)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                
                // Fixed height container for scanning indicator to prevent UI shifting
                VStack {
                    if viewModel.isScanning {
                        HStack(spacing: 6) {
                            ProgressView()
                                .scaleEffect(0.6)
                                .tint(Colors.accent)
                            
                            Text("Scanning ports...")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(Colors.textSecondary)
                        }
                        .transition(.opacity)
                    }
                }
                .frame(height: viewModel.isScanning ? 20 : 0)
                .padding(.horizontal, 16)
                .animation(.easeInOut(duration: 0.2), value: viewModel.isScanning)
            }
            
            // Subtle separator instead of prominent divider
            Rectangle()
                .fill(Colors.textSecondary.opacity(0.1))
                .frame(height: 0.5)
                .padding(.horizontal, 16)
                .padding(.top, 8)
            
            // Process list with modern cards
            ScrollView {
                LazyVStack(spacing: 6) {
                    if viewModel.processes.isEmpty && !viewModel.isScanning {
                        VStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 24, weight: .light))
                                .foregroundColor(Colors.textSecondary)
                            
                            Text("No processes found")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Colors.textSecondary)
                            
                            Text("Try refreshing to scan for active processes")
                                .font(.system(size: 10))
                                .foregroundColor(Colors.textSecondary.opacity(0.7))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.vertical, 24)
                    } else {
                        ForEach(viewModel.processes) { process in
                            ProcessRowView(
                                process: process,
                                onKill: {
                                    Task {
                                        await killProcess(pid: Int(process.pid))
                                    }
                                }
                            )
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .frame(maxHeight: 180)
        }
        .background(Colors.background)
        .onAppear {
            refreshProcesses()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
    
    private func refreshProcesses() {
        scanTask?.cancel()
        scanTask = Task {
            await viewModel.refreshProcesses()
        }
    }
    
    private func killProcess(pid: Int) async {
        await viewModel.killProcess(ProcessInfo(pid: Int32(pid), port: 0, command: "", name: ""))
    }
}

// MARK: - ProcessRowView

struct ProcessRowView: View {
    let process: ProcessInfo
    let onKill: () -> Void
    @State private var isHovered = false
    @State private var killTask: Task<Void, Never>?
    
    var body: some View {
        HStack(spacing: 12) {
            // Process icon with color coding
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [MenuBarView.Colors.accent.opacity(0.15), MenuBarView.Colors.accent.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 32, height: 32)
                
                Image(systemName: "gear.circle.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(MenuBarView.Colors.accent)
            }
            
            // Process info
            VStack(alignment: .leading, spacing: 2) {
                Text(process.name)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(MenuBarView.Colors.textPrimary)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    Text("Port: \(process.port)")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(MenuBarView.Colors.accent)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(MenuBarView.Colors.accent.opacity(0.1))
                        .clipShape(Capsule())
                    
                    Text("PID: \(process.pid)")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(MenuBarView.Colors.textSecondary)
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
                                colors: [MenuBarView.Colors.danger, MenuBarView.Colors.danger.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [MenuBarView.Colors.danger.opacity(0.7), MenuBarView.Colors.danger.opacity(0.5)],
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
                    MenuBarView.Colors.surface.opacity(0.8) : 
                    MenuBarView.Colors.surface.opacity(0.3)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(
                    isHovered ? MenuBarView.Colors.accent.opacity(0.3) : Color.clear,
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

#Preview {
    MenuBarView()
        .frame(width: 300, height: 280)
        .background(Color(NSColor.windowBackgroundColor))
}
