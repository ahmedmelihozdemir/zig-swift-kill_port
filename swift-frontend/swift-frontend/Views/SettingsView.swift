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
    @Environment(\.dismiss) private var dismiss
    
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
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Colors.accent, Colors.accent.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "gear")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Settings")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Colors.textPrimary)
                        
                        Text("Configure Port Monitor preferences")
                            .font(.system(size: 13))
                            .foregroundColor(Colors.textSecondary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        dismiss()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Colors.surface)
                                .frame(width: 28, height: 28)
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Colors.textSecondary)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Colors.accent.opacity(0.3), Colors.accent.opacity(0.1)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 2)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 16)
            .background(
                LinearGradient(
                    colors: [Colors.background, Colors.background.opacity(0.95)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Auto Refresh Settings
                    ModernSettingsSection(
                        title: "Auto Refresh", 
                        icon: "arrow.clockwise",
                        iconColor: Colors.success
                    ) {
                        VStack(alignment: .leading, spacing: 16) {
                            ModernToggle(
                                title: "Enable auto refresh",
                                subtitle: "Automatically scan for processes",
                                isOn: $autoRefreshEnabled
                            )
                            
                            if autoRefreshEnabled {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Text("Refresh interval")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(Colors.textPrimary)
                                        
                                        Spacer()
                                        
                                        Text("\(Int(refreshInterval))s")
                                            .font(.system(size: 13, weight: .semibold, design: .monospaced))
                                            .foregroundColor(Colors.accent)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 2)
                                            .background(Colors.accent.opacity(0.1))
                                            .clipShape(Capsule())
                                    }
                                    
                                    Slider(value: $refreshInterval, in: 1...60, step: 1)
                                        .tint(Colors.accent)
                                }
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }
                    }
                    
                    // Notification Settings
                    ModernSettingsSection(
                        title: "Notifications", 
                        icon: "bell.fill",
                        iconColor: Colors.warning
                    ) {
                        VStack(alignment: .leading, spacing: 16) {
                            ModernToggle(
                                title: "Show notifications",
                                subtitle: "Get notified about process kills and errors",
                                isOn: $showNotifications
                            )
                        }
                    }
                    
                    // Appearance Settings
                    ModernSettingsSection(
                        title: "Appearance", 
                        icon: "paintbrush.fill",
                        iconColor: Colors.accent
                    ) {
                        VStack(alignment: .leading, spacing: 16) {
                            ModernToggle(
                                title: "Minimalist mode",
                                subtitle: "Reduce visual elements for cleaner interface",
                                isOn: $minimalistMode
                            )
                        }
                    }
                    
                    // Monitored Ports Settings
                    ModernSettingsSection(
                        title: "Monitored Ports", 
                        icon: "network",
                        iconColor: Colors.success
                    ) {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Active monitoring ports")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Colors.textPrimary)
                            
                            // Current ports grid
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 10) {
                                ForEach(monitoredPorts, id: \.self) { port in
                                    ModernPortBadge(port: port) {
                                        removePort(port)
                                    }
                                }
                            }
                            
                            // Add new port
                            HStack(spacing: 12) {
                                TextField("Add port (e.g., 3000)", text: $newPort)
                                    .textFieldStyle(ModernTextFieldStyle())
                                    .onSubmit {
                                        addPort()
                                    }
                                
                                Button(action: addPort) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "plus")
                                            .font(.system(size: 10, weight: .bold))
                                        Text("Add")
                                            .font(.system(size: 12, weight: .semibold))
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        LinearGradient(
                                            colors: newPort.isEmpty ? [Colors.textSecondary, Colors.textSecondary] : [Colors.accent, Colors.accent.opacity(0.8)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .clipShape(Capsule())
                                }
                                .buttonStyle(PlainButtonStyle())
                                .disabled(newPort.isEmpty)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Common development ports:")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Colors.textSecondary)
                                
                                Text("3000 (React), 4000 (Express), 5000 (Flask), 8000 (Django), 8080 (Tomcat)")
                                    .font(.system(size: 11))
                                    .foregroundColor(Colors.textSecondary.opacity(0.8))
                            }
                        }
                    }
                    
                    
                    // About Section
                    ModernSettingsSection(
                        title: "About", 
                        icon: "info.circle.fill",
                        iconColor: Colors.textSecondary
                    ) {
                        VStack(alignment: .leading, spacing: 16) {
                            VStack(spacing: 8) {
                                InfoRow(label: "Version", value: "1.0.0")
                                InfoRow(label: "Author", value: "Ahmed Melih Özdemir")
                                InfoRow(label: "Platform", value: "macOS")
                            }
                            
                            Rectangle()
                                .fill(Colors.textSecondary.opacity(0.2))
                                .frame(height: 1)
                            
                            HStack(spacing: 12) {
                                ModernLinkButton(
                                    title: "GitHub",
                                    icon: "link",
                                    action: {
                                        if let url = URL(string: "https://github.com/ahmedmelihozdemir/zig-swift-kill_port") {
                                            NSWorkspace.shared.open(url)
                                        }
                                    }
                                )
                                
                                ModernLinkButton(
                                    title: "Report Issue",
                                    icon: "exclamationmark.triangle",
                                    action: {
                                        if let url = URL(string: "https://github.com/ahmedmelihozdemir/zig-swift-kill_port/issues") {
                                            NSWorkspace.shared.open(url)
                                        }
                                    }
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            
            // Modern Footer
            HStack(spacing: 16) {
                Button("Reset to Defaults") {
                    resetToDefaults()
                }
                .buttonStyle(ModernSecondaryButtonStyle())
                
                Spacer()
                
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(ModernPrimaryButtonStyle())
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(Colors.surface.opacity(0.5))
        }
        .frame(width: 560, height: 680)
        .background(Colors.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 6)
        .onAppear {
            loadMonitoredPorts()
        }
        .onChange(of: monitoredPorts) {
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

// MARK: - Modern UI Components

struct ModernSettingsSection<Content: View>: View {
    let title: String
    let icon: String
    let iconColor: Color
    let content: Content
    
    init(title: String, icon: String, iconColor: Color, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.iconColor = iconColor
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(iconColor)
                }
                
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(SettingsView.Colors.textPrimary)
            }
            
            content
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(SettingsView.Colors.surface.opacity(0.5))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(SettingsView.Colors.textSecondary.opacity(0.1), lineWidth: 1)
        )
    }
}

struct ModernToggle: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(SettingsView.Colors.textPrimary)
                
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(SettingsView.Colors.textSecondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: SettingsView.Colors.accent))
                .scaleEffect(0.9)
        }
    }
}

struct ModernPortBadge: View {
    let port: Int
    let onRemove: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 6) {
            Text("\(port)")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
            
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.white.opacity(0.9))
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            LinearGradient(
                colors: isHovered ? [SettingsView.Colors.danger, SettingsView.Colors.danger.opacity(0.8)] : [SettingsView.Colors.accent, SettingsView.Colors.accent.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(Capsule())
        .scaleEffect(isHovered ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

struct ModernTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .font(.system(size: 12, weight: .medium))
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(SettingsView.Colors.surface)
                    .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
            )
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(SettingsView.Colors.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(SettingsView.Colors.textPrimary)
        }
    }
}

struct ModernLinkButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .medium))
                
                Text(title)
                    .font(.system(size: 12, weight: .medium))
            }
            .foregroundColor(isHovered ? SettingsView.Colors.accent : SettingsView.Colors.textSecondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isHovered ? SettingsView.Colors.accent.opacity(0.1) : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
}

struct ModernPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(
                LinearGradient(
                    colors: [SettingsView.Colors.accent, SettingsView.Colors.accent.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct ModernSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .medium))
            .foregroundColor(SettingsView.Colors.textSecondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(SettingsView.Colors.surface)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(SettingsView.Colors.textSecondary.opacity(0.3), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    SettingsView()
}
