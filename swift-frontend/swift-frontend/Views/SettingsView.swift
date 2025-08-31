//
//  SettingsView.swift
//  swift-frontend
//
//  Created by Melih Özdemir on 31.08.2025.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("autoRefreshEnabled") private var autoRefreshEnabled = true
    @AppStorage("refreshInterval") private var refreshInterval = 5.0
    @AppStorage("showNotifications") private var showNotifications = true
    @AppStorage("minimalistMode") private var minimalistMode = false
    @AppStorage("monitoredPorts") private var monitoredPortsString = "3000,3001,3002,3003,4000,5000,8000,8080,8888,9000"
    
    @State private var monitoredPorts: [Int] = []
    @State private var newPort: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "gear")
                        .font(.title2)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Settings")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Configure Swift Frontend preferences")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Divider()
            }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Auto Refresh Settings
                    SettingsSection(title: "Auto Refresh", icon: "arrow.clockwise") {
                        VStack(alignment: .leading, spacing: 12) {
                            Toggle("Enable auto refresh", isOn: $autoRefreshEnabled)
                                .toggleStyle(SwitchToggleStyle(tint: .blue))
                            
                            if autoRefreshEnabled {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("Refresh interval:")
                                        Spacer()
                                        Text("\(Int(refreshInterval)) seconds")
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Slider(value: $refreshInterval, in: 1...60, step: 1)
                                        .accentColor(.blue)
                                }
                            }
                        }
                    }
                    
                    // Notification Settings
                    SettingsSection(title: "Notifications", icon: "bell") {
                        VStack(alignment: .leading, spacing: 12) {
                            Toggle("Show notifications", isOn: $showNotifications)
                                .toggleStyle(SwitchToggleStyle(tint: .blue))
                            
                            Text("Get notified when processes are killed or errors occur")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Appearance Settings
                    SettingsSection(title: "Appearance", icon: "paintbrush") {
                        VStack(alignment: .leading, spacing: 12) {
                            Toggle("Minimalist mode", isOn: $minimalistMode)
                                .toggleStyle(SwitchToggleStyle(tint: .blue))
                            
                            Text("Reduce visual elements for a cleaner interface")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Monitored Ports Settings
                    SettingsSection(title: "Monitored Ports", icon: "network") {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Ports to monitor for active processes:")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            // Current ports
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                                ForEach(monitoredPorts, id: \.self) { port in
                                    PortBadge(port: port) {
                                        removePort(port)
                                    }
                                }
                            }
                            
                            // Add new port
                            HStack {
                                TextField("Add port (e.g., 3000)", text: $newPort)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .onSubmit {
                                        addPort()
                                    }
                                
                                Button("Add") {
                                    addPort()
                                }
                                .buttonStyle(.borderedProminent)
                                .disabled(newPort.isEmpty)
                            }
                            
                            Text("Common ports: 3000 (React), 4000 (Express), 5000 (Flask), 8000 (Django), 8080 (Tomcat)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // About Section
                    SettingsSection(title: "About", icon: "info.circle") {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Version:")
                                Spacer()
                                Text("1.0.0")
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack {
                                Text("Author:")
                                Spacer()
                                Text("Ahmed Melih Özdemir")
                                    .foregroundColor(.secondary)
                            }
                            
                            Divider()
                            
                            Button("View on GitHub") {
                                if let url = URL(string: "https://github.com/ahmedmelihozdemir/zig-swift-kill_port") {
                                    NSWorkspace.shared.open(url)
                                }
                            }
                            .buttonStyle(.link)
                            
                            Button("Report an Issue") {
                                if let url = URL(string: "https://github.com/ahmedmelihozdemir/zig-swift-kill_port/issues") {
                                    NSWorkspace.shared.open(url)
                                }
                            }
                            .buttonStyle(.link)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            
            // Footer buttons
            HStack {
                Button("Reset to Defaults") {
                    resetToDefaults()
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button("Done") {
                    // Close settings window
                    NSApplication.shared.keyWindow?.close()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .frame(width: 500, height: 600)
        .onAppear {
            loadMonitoredPorts()
        }
        .onChange(of: monitoredPorts) { _ in
            saveMonitoredPorts()
        }
    }
    
    private func loadMonitoredPorts() {
        monitoredPorts = monitoredPortsString
            .split(separator: ",")
            .compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
            .sorted()
    }
    
    private func saveMonitoredPorts() {
        monitoredPortsString = monitoredPorts.map(String.init).joined(separator: ",")
    }
    
    private func addPort() {
        guard let port = Int(newPort.trimmingCharacters(in: .whitespaces)),
              port > 0 && port <= 65535,
              !monitoredPorts.contains(port) else {
            return
        }
        
        monitoredPorts.append(port)
        monitoredPorts.sort()
        newPort = ""
    }
    
    private func removePort(_ port: Int) {
        monitoredPorts.removeAll { $0 == port }
    }
    
    private func resetToDefaults() {
        autoRefreshEnabled = true
        refreshInterval = 5.0
        showNotifications = true
        minimalistMode = false
        monitoredPortsString = "3000,3001,3002,3003,4000,5000,8000,8080,8888,9000"
        loadMonitoredPorts()
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .frame(width: 16)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            content
                .padding(.leading, 24)
        }
        .padding(16)
        .background(Color(.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct PortBadge: View {
    let port: Int
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text("\(port)")
                .font(.caption)
                .fontWeight(.semibold)
            
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 8))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.blue)
        .foregroundColor(.white)
        .clipShape(Capsule())
    }
}

#Preview {
    SettingsView()
}
