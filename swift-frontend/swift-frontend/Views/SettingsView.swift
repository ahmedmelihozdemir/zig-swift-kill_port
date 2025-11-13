import SwiftUI

struct SettingsView: View {
    @AppStorage("autoRefreshEnabled") private var autoRefreshEnabled = true
    @AppStorage("refreshInterval") private var refreshInterval = 5.0
    @AppStorage("showNotifications") private var showNotifications = true
    @AppStorage("minimalistMode") private var minimalistMode = false
    @AppStorage("useRangeScanning") private var useRangeScanning = false
    @AppStorage("monitoredPorts") private var monitoredPortsString = "1446,1447,1448,1449,3000,3001,3002,3003,3004, 3005,3006,4000,5000,5672,6379,8000,8080,8888,9000,6379,6380,6381,6382,5672,15672,5673,15673,5674,15674,5675,15675,"
    
    @State private var monitoredPorts: [Int] = []
    @State private var newPort: String = ""
    @Environment(\.dismiss) private var dismiss
    
    private let onSettingsChanged: (() -> Void)?
    
    init(onSettingsChanged: (() -> Void)? = nil) {
        self.onSettingsChanged = onSettingsChanged
    }
    
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
            // Compact Header
            VStack(alignment: .leading, spacing: 8) {
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
                            .frame(width: 24, height: 24)
                        
                        Image(systemName: "gear")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Settings")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Colors.textPrimary)
                        
                        Text("Configure preferences")
                            .font(.system(size: 10))
                            .foregroundColor(Colors.textSecondary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        dismiss()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Colors.surface)
                                .frame(width: 20, height: 20)
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 8, weight: .medium))
                                .foregroundColor(Colors.textSecondary)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    // Auto Refresh Settings
                    CompactSettingsSection(
                        title: "Auto Refresh", 
                        icon: "arrow.clockwise",
                        iconColor: Colors.success
                    ) {
                        VStack(alignment: .leading, spacing: 8) {
                            CompactToggle(
                                title: "Enable auto refresh",
                                subtitle: "Automatically scan for processes",
                                isOn: $autoRefreshEnabled
                            )
                            
                            if autoRefreshEnabled {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text("Refresh interval")
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundColor(Colors.textPrimary)
                                        
                                        Spacer()
                                        
                                        Text("\(Int(refreshInterval))s")
                                            .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                            .foregroundColor(Colors.accent)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 1)
                                            .background(Colors.accent.opacity(0.1))
                                            .clipShape(Capsule())
                                    }
                                    
                                    Slider(value: $refreshInterval, in: 1...60, step: 1)
                                        .tint(Colors.accent)
                                        .scaleEffect(0.9)
                                }
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }
                    }
                    
                    // Notification Settings
                    CompactSettingsSection(
                        title: "Notifications", 
                        icon: "bell.fill",
                        iconColor: Colors.warning
                    ) {
                        VStack(alignment: .leading, spacing: 8) {
                            CompactToggle(
                                title: "Show notifications",
                                subtitle: "Get notified about process kills",
                                isOn: $showNotifications
                            )
                        }
                    }
                    
                    // Monitored Ports Settings
                    CompactSettingsSection(
                        title: "Monitored Ports", 
                        icon: "network",
                        iconColor: Colors.success
                    ) {
                        VStack(alignment: .leading, spacing: 8) {
                            // Scanning mode toggle
                            CompactToggle(
                                title: "Port Range Scanning",
                                subtitle: useRangeScanning ? "Scanning ports 3000-9999 (\(7000) ports)" : "Monitoring specific ports only",
                                isOn: $useRangeScanning
                            )
                            .onChange(of: useRangeScanning) { oldValue, newValue in
                                UserDefaults.standard.set(newValue, forKey: "useRangeScanning")
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    onSettingsChanged?()
                                }
                            }
                            
                            if !useRangeScanning {
                            // Current ports grid
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 5), spacing: 6) {
                                ForEach(monitoredPorts, id: \.self) { port in
                                    CompactPortBadge(port: port) {
                                        removePort(port)
                                    }
                                }
                            }
                            
                            // Add new port
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 8) {
                                    // Search-style port input
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(Colors.surface)
                                            .stroke(newPort.isEmpty ? Color.clear : Colors.accent.opacity(0.3), lineWidth: 1)
                                            .frame(height: 24)
                                        
                                        HStack(spacing: 6) {
                                            Image(systemName: "number")
                                                .font(.system(size: 9, weight: .medium))
                                                .foregroundColor(Colors.textSecondary)
                                            
                                            TextField("Add port...", text: $newPort)
                                                .font(.system(size: 10, weight: .medium))
                                                .textFieldStyle(PlainTextFieldStyle())
                                                .foregroundColor(Colors.textPrimary)
                                                .onSubmit {
                                                    addPort()
                                                }
                                        }
                                        .padding(.horizontal, 8)
                                    }
                                    
                                    // Plus button
                                    Button(action: addPort) {
                                        ZStack {
                                            Circle()
                                                .fill(newPort.isEmpty ? Colors.surface : Colors.accent)
                                                .frame(width: 24, height: 24)
                                            
                                            Image(systemName: "plus")
                                                .font(.system(size: 10, weight: .bold))
                                                .foregroundColor(newPort.isEmpty ? Colors.textSecondary : .white)
                                        }
                                    }
                                    .disabled(newPort.isEmpty)
                                    .buttonStyle(PlainButtonStyle())
                                    .scaleEffect(newPort.isEmpty ? 1.0 : 1.1)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: newPort.isEmpty)
                                    
                                    // Clear button (when text is entered)
                                    if !newPort.isEmpty {
                                        Button(action: { newPort = "" }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.system(size: 10))
                                                .foregroundColor(Colors.textSecondary)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .transition(.opacity)
                                    }
                                }
                                
                                Text("Common: 3000, 5672, 6379, 8000, 8080, 15672")
                                    .font(.system(size: 9))
                                    .foregroundColor(Colors.textSecondary.opacity(0.8))
                            }
                            } // End of !useRangeScanning if block
                        }
                    }
                    
                    
                    // About Section
                    CompactSettingsSection(
                        title: "About", 
                        icon: "info.circle.fill",
                        iconColor: Colors.textSecondary
                    ) {
                        VStack(alignment: .leading, spacing: 8) {
                            VStack(spacing: 4) {
                                CompactInfoRow(label: "Version", value: "1.0.0")
                                CompactInfoRow(label: "Platform", value: "macOS")
                            }
                            
                            HStack(spacing: 8) {
                                CompactLinkButton(
                                    title: "GitHub",
                                    icon: "link",
                                    action: {
                                        if let url = URL(string: "https://github.com/ahmedmelihozdemir/zig-swift-kill_port") {
                                            NSWorkspace.shared.open(url)
                                        }
                                    }
                                )
                                
                                CompactLinkButton(
                                    title: "Issues",
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
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            
            // Compact Footer
            HStack(spacing: 12) {
                Button("Reset") {
                    resetToDefaults()
                }
                .buttonStyle(CompactSecondaryButtonStyle())
                
                Spacer()
                
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(CompactPrimaryButtonStyle())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Colors.surface.opacity(0.3))
        }
        .frame(width: 400, height: 480)
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
        monitoredPortsString = "3000,3001,3002,3003,4000,5000,5672,6379,8000,8080,8888,9000,15672"
        loadMonitoredPorts()
    }
}

// MARK: - Compact UI Components

struct CompactSettingsSection<Content: View>: View {
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
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 20, height: 20)
                    
                    Image(systemName: icon)
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(iconColor)
                }
                
                Text(title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(SettingsView.Colors.textPrimary)
            }
            
            content
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(SettingsView.Colors.surface.opacity(0.3))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(SettingsView.Colors.textSecondary.opacity(0.1), lineWidth: 1)
        )
    }
}

struct CompactToggle: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(SettingsView.Colors.textPrimary)
                
                Text(subtitle)
                    .font(.system(size: 9))
                    .foregroundColor(SettingsView.Colors.textSecondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: SettingsView.Colors.accent))
                .scaleEffect(0.8)
        }
    }
}

struct CompactPortBadge: View {
    let port: Int
    let onRemove: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 4) {
            Text(String(port))
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
            
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 6, weight: .bold))
                    .foregroundColor(.white.opacity(0.9))
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
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

struct CompactTextFieldStyle: TextFieldStyle {
    @State private var isFocused = false
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(SettingsView.Colors.textPrimary)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(SettingsView.Colors.surface)
                    .stroke(
                        isFocused ? SettingsView.Colors.accent.opacity(0.5) : SettingsView.Colors.textSecondary.opacity(0.2),
                        lineWidth: 1
                    )
            )
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isFocused = true
                }
            }
            .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

struct CompactInfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(SettingsView.Colors.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(SettingsView.Colors.textPrimary)
        }
    }
}

struct CompactLinkButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 8, weight: .medium))
                
                Text(title)
                    .font(.system(size: 9, weight: .medium))
            }
            .foregroundColor(isHovered ? SettingsView.Colors.accent : SettingsView.Colors.textSecondary)
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 4)
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

struct CompactPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
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

struct CompactSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(SettingsView.Colors.textSecondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
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
