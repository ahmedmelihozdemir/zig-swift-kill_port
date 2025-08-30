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
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Image(systemName: "bolt.circle.fill")
                    .foregroundColor(.blue)
                Text("Port Kill Monitor")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: {
                    viewModel.refreshProcesses()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(viewModel.isScanning)
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)
            
            Divider()
            
            // Status
            HStack {
                if viewModel.isScanning {
                    ProgressView()
                        .scaleEffect(0.6)
                        .controlSize(.mini)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.statusInfo.text)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(viewModel.statusInfo.tooltip)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.horizontal, 12)
            
            // Process List
            if viewModel.processes.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.circle")
                        .font(.title2)
                        .foregroundColor(.green)
                    
                    Text("No active processes")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("All monitored ports are free")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            } else {
                ScrollView {
                    LazyVStack(spacing: 6) {
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
                    .padding(.horizontal, 8)
                }
                .frame(maxHeight: 300)
                
                Divider()
                
                // Kill All Button
                Button(action: {
                    viewModel.killAllProcesses()
                }) {
                    HStack {
                        if viewModel.isKilling {
                            ProgressView()
                                .scaleEffect(0.6)
                                .controlSize(.mini)
                        } else {
                            Image(systemName: "trash.fill")
                        }
                        
                        Text("Kill All Processes")
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(6)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(viewModel.processes.isEmpty || viewModel.isKilling)
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
            }
            
            Divider()
            
            // Footer
            HStack {
                Button("Settings") {
                    // TODO: Implement settings
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(.secondary)
                
                Spacer()
                
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(.secondary)
            }
            .font(.caption)
            .padding(.horizontal, 12)
            .padding(.bottom, 8)
        }
        .frame(width: 320)
        .background(Color(.controlBackgroundColor))
        .alert("Error", isPresented: $viewModel.showingError) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}

struct ProcessRowView: View {
    let process: ProcessInfo
    let isKilling: Bool
    let onKill: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Port Badge
            VStack(spacing: 2) {
                Text("\(process.port)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.blue)
                    .cornerRadius(4)
                
                Text("PORT")
                    .font(.system(size: 8))
                    .foregroundColor(.secondary)
            }
            
            // Process Info
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(process.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text("PID: \(process.pid)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(Color(.quaternaryLabelColor))
                        .cornerRadius(3)
                }
                
                Text(process.command)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            
            // Kill Button
            Button(action: onKill) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(.red)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(isKilling)
            .opacity(isKilling ? 0.5 : 1.0)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color(.controlBackgroundColor))
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color(.separatorColor), lineWidth: 0.5)
        )
    }
}

#Preview {
    MenuBarView()
}
