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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Compact Header
            VStack(spacing: 6) {
                HStack(spacing: 8) {
                    Image(systemName: "cpu.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Swift Frontend")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.primary)
                        
                        Text("\(viewModel.processes.count) processes")
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Refresh button
                    Button(action: {
                        refreshProcesses()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 10))
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(viewModel.isScanning)
                    
                    // Status indicator
                    Circle()
                        .fill(viewModel.isScanning ? Color.green : Color.gray)
                        .frame(width: 5, height: 5)
                        .scaleEffect(viewModel.isScanning ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: viewModel.isScanning)
                }
                .padding(.horizontal, 10)
                .padding(.top, 8)
                
                // Compact scanning indicator
                if viewModel.isScanning {
                    HStack(spacing: 4) {
                        ProgressView()
                            .scaleEffect(0.5)
                        Text("Scanning...")
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 10)
                    .transition(.opacity)
                }
            }
            .padding(.bottom, 6)
            .background(Color(NSColor.windowBackgroundColor))
            
            Divider()
                .padding(.horizontal, 10)
            
            // Process List
            ScrollView {
                LazyVStack(spacing: 4) {
                    if viewModel.processes.isEmpty && !viewModel.isScanning {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.green)
                            Text("No processes on monitored ports")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 20)
                    } else {
                        ForEach(viewModel.processes, id: \.id) { process in
                            ProcessRowView(
                                process: process,
                                onKill: {
                                    killProcess(process)
                                }
                            )
                            .padding(.horizontal, 8)
                        }
                    }
                }
                .padding(.vertical, 6)
            }
            .frame(height: 150)
            
            Divider()
                .padding(.horizontal, 10)
            
            // Compact Footer
            HStack(spacing: 12) {
                Button("Settings") {
                    // TODO: Open settings
                }
                .font(.system(size: 10))
                .foregroundColor(.blue)
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                Button("Quit") {
                    NSApp.terminate(nil)
                }
                .font(.system(size: 10))
                .foregroundColor(.red)
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
        }
        .frame(width: 280, height: 250)
        .background(Color(NSColor.windowBackgroundColor))
        .onAppear {
            // Initial scan when popover opens
            refreshProcesses()
        }
        .onDisappear {
            // Cancel any ongoing scan task when view disappears
            scanTask?.cancel()
            scanTask = nil
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
    
    var body: some View {
        HStack(spacing: 6) {
            // Port indicator
            Text("\(process.port)")
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundColor(.blue)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 4))
            
            VStack(alignment: .leading, spacing: 1) {
                Text(process.name)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text("PID: \(process.pid)")
                    .font(.system(size: 8))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Kill button
            Button(action: handleKillAction) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.red)
            }
            .buttonStyle(PlainButtonStyle())
            .opacity(isHovered ? 1.0 : 0.6)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(isHovered ? Color(NSColor.controlBackgroundColor) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 6))
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
        .frame(width: 280, height: 250)
}
