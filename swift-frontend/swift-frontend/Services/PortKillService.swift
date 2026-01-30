import Foundation
import Combine

enum PortKillError: Error, LocalizedError {
    case processNotFound
    case commandFailed
    case killFailed
    case parseError
    case backendNotFound
    
    var errorDescription: String? {
        switch self {
        case .processNotFound:
            return "Process not found on port"
        case .commandFailed:
            return "Command execution failed"
        case .killFailed:
            return "Failed to kill process"
        case .parseError:
            return "Failed to parse backend response"
        case .backendNotFound:
            return "Zig backend executable not found"
        }
    }
}

@MainActor
final class PortKillService: ObservableObject {
    @Published private(set) var processes: [ProcessInfo] = []
    @Published private(set) var isScanning: Bool = false
    @Published private(set) var lastError: PortKillError?
    @Published private(set) var statusInfo: StatusBarInfo = StatusBarInfo.fromProcessCount(0)
    
    private var scanTimer: Timer?
    private let backendPath: String
    private var monitoredPorts: [UInt16] = []
    private var isDestroyed = false
    private var currentScanTask: Task<Void, Never>?
    
    init(backendPath: String = "") {
        if backendPath.isEmpty {
            self.backendPath = Self.findBackendExecutable()
        } else {
            self.backendPath = backendPath
        }
        
        // Load monitored ports from UserDefaults
        loadMonitoredPorts()
    }
    
    private func loadMonitoredPorts() {
        let useRangeScanning = UserDefaults.standard.bool(forKey: "useRangeScanning")
        
        if useRangeScanning {
            // Development port range (3000-9999) - captures most dev servers
            let rangePorts = Array(3000...9999).map { UInt16($0) }
            self.monitoredPorts = rangePorts
            NSLog("🔧 Using port range scanning: 3000-9999 (\(rangePorts.count) ports)")
            print("🔧 Using port range scanning: 3000-9999 (\(rangePorts.count) ports)")
        } else {
            // Specific ports mode (faster)
            let defaultPorts = "3000,3001,3002,3003,4000,5000,5672,6379,8000,8080,8888,9000,15672"
            let portsString = UserDefaults.standard.string(forKey: "monitoredPorts") ?? defaultPorts
            
            let ports = portsString.components(separatedBy: ",")
                .compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }
                .filter { $0 > 0 && $0 <= 65535 }
                .map { UInt16($0) }
            
            self.monitoredPorts = ports.isEmpty ? [3000, 3001, 5672, 6379, 8000, 8080, 5000, 9000, 15672] : ports
            
            NSLog("🔧 Loaded specific monitored ports: \(self.monitoredPorts)")
            print("🔧 Loaded specific monitored ports: \(self.monitoredPorts)")
        }
    }
    
    func updateMonitoredPorts() {
        loadMonitoredPorts()
    }
    
    private static func findBackendExecutable() -> String {
        // Try to find the zig backend executable
        let possiblePaths = [
            "../zig-backend/zig-out/bin/port-kill",
            "../../zig-backend/zig-out/bin/port-kill",
            "./zig-backend/zig-out/bin/port-kill",
            "/usr/local/bin/port-kill"
        ]
        
        for path in possiblePaths {
            let expandedPath = NSString(string: path).expandingTildeInPath
            if FileManager.default.fileExists(atPath: expandedPath) {
                return expandedPath
            }
        }
        
        return "../zig-backend/zig-out/bin/port-kill" // Default fallback
    }
    
    // Manual scan function - only scans when called
    func manualScan() async {
        guard !isDestroyed else { return }
        await scanProcesses()
    }
    
    func stopScanning() {
        scanTimer?.invalidate()
        scanTimer = nil
        currentScanTask?.cancel()
        currentScanTask = nil
        isScanning = false
    }
    
    func scanProcesses() async {
        guard !isDestroyed else { return }
        
        // Cancel any existing scan
        currentScanTask?.cancel()
        
        currentScanTask = Task { [weak self] in
            guard let self = self else { return }
            
            await MainActor.run {
                self.isScanning = true
                self.lastError = nil
            }
            
            NSLog("🔍 DEBUG: scanProcesses() called - monitoring ports: \(self.monitoredPorts)")
            print("📡 Scanning ports: \(self.monitoredPorts)")
            
            do {
                let newProcesses = try await self.scanPortsDirectly()
                
                guard !self.isDestroyed else { return }
                
                NSLog("🔍 DEBUG: scanPortsDirectly() returned \(newProcesses.count) processes")
                print("✅ Found \(newProcesses.count) processes")
                for process in newProcesses {
                    print("   Port \(process.port): \(process.name) (PID: \(process.pid))")
                }
                
                await MainActor.run {
                    self.processes = newProcesses.filter(\.isValid)
                    self.statusInfo = StatusBarInfo.fromProcessCount(newProcesses.count)
                    self.isScanning = false
                }
            } catch let error as PortKillError {
                guard !self.isDestroyed else { return }
                print("❌ PortKill error: \(error.localizedDescription)")
                await MainActor.run {
                    self.lastError = error
                    self.isScanning = false
                }
            } catch {
                guard !self.isDestroyed else { return }
                print("❌ General error: \(error)")
                await MainActor.run {
                    self.lastError = .commandFailed
                    self.isScanning = false
                }
            }
        }
        
        await currentScanTask?.value
        currentScanTask = nil
    }
    
    private func scanPortsDirectly() async throws -> [ProcessInfo] {
        guard !isDestroyed else { return [] }
        
        var foundProcesses: [ProcessInfo] = []
        
        for port in monitoredPorts {
            guard !isDestroyed else { break }
            
            do {
                let processInfo = try await getProcessOnPort(port)
                NSLog("🔍 DEBUG: Successfully found process on port \(port): \(processInfo)")
                foundProcesses.append(processInfo)
            } catch {
                NSLog("🔍 DEBUG: Error checking port \(port): \(error)")
                print("⚠️ Error checking port \(port): \(error)")
            }
        }
        
        return foundProcesses
    }
    
    private func getProcessOnPort(_ port: UInt16) async throws -> ProcessInfo {
        guard !isDestroyed else { throw PortKillError.processNotFound }
        
        // Use lsof to find processes listening on the port (both IPv4 and IPv6)
        NSLog("🔍 DEBUG: Checking port \(port)")
        print("🔍 Checking port \(port)")
        
        return try await withCheckedThrowingContinuation { continuation in
            let lsofProcess = Process()
            lsofProcess.executableURL = URL(fileURLWithPath: "/usr/sbin/lsof")
            lsofProcess.arguments = ["-i", ":\(port)", "-sTCP:LISTEN"]
            
            let pipe = Pipe()
            lsofProcess.standardOutput = pipe
            lsofProcess.standardError = Pipe()
            
            lsofProcess.terminationHandler = { process in
                guard process.terminationStatus == 0 else {
                    continuation.resume(throwing: PortKillError.processNotFound)
                    return
                }
                
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                
                NSLog("🔍 DEBUG: lsof output for port \(port): '\(output)'")
                print("📝 lsof output for port \(port): '\(output)'")
                
                guard !output.isEmpty else {
                    print("❌ Empty lsof output for port \(port)")
                    continuation.resume(throwing: PortKillError.processNotFound)
                    return
                }
                
                // Parse lsof output to extract PID
                let lines = output.components(separatedBy: .newlines)
                guard lines.count > 1 else {
                    print("❌ Not enough lines in lsof output for port \(port)")
                    continuation.resume(throwing: PortKillError.processNotFound)
                    return
                }
                
                let processLine = lines[1]
                print("📋 Process line: '\(processLine)'")
                let components = processLine.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
                print("📋 Components: \(components)")
                
                guard components.count >= 2, let pid = Int32(components[1]) else {
                    print("❌ Could not parse PID from components for port \(port)")
                    continuation.resume(throwing: PortKillError.parseError)
                    return
                }
                
                print("✅ Found PID \(pid) for port \(port)")
                
                // Get process details
                Task {
                    do {
                        let processInfo = try await self.getProcessDetails(pid: pid, port: port)
                        continuation.resume(returning: processInfo)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
            
            do {
                try lsofProcess.run()
            } catch {
                continuation.resume(throwing: PortKillError.commandFailed)
            }
        }
    }
    
    private func getProcessDetails(pid: Int32, port: UInt16) async throws -> ProcessInfo {
        let psProcess = Process()
        psProcess.executableURL = URL(fileURLWithPath: "/bin/ps")
        psProcess.arguments = ["-p", "\(pid)", "-o", "comm="]
        
        let pipe = Pipe()
        psProcess.standardOutput = pipe
        psProcess.standardError = Pipe()
        
        try psProcess.run()
        psProcess.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let command = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "unknown"
        
        // Extract process name (basename of command)
        let name = URL(fileURLWithPath: command).lastPathComponent
        
        return ProcessInfo(pid: pid, port: port, command: command, name: name)
    }
    
    func killProcess(_ processInfo: ProcessInfo) async throws {
        guard !isDestroyed else { return }
        
        try await killProcessByPID(processInfo.pid)
        
        // Refresh the process list after killing
        await scanProcesses()
    }
    
    func killAllProcesses() async throws {
        guard !isDestroyed else { return }
        
        for processInfo in processes {
            guard !isDestroyed else { break }
            try await killProcessByPID(processInfo.pid)
        }
        
        // Refresh the process list after killing all
        await scanProcesses()
    }
    
    func destroy() {
        guard !isDestroyed else { return }
        
        isDestroyed = true
        currentScanTask?.cancel()
        currentScanTask = nil
        stopScanning()
        
        print("✅ PortKillService destroyed")
    }
    
    deinit {
        print("🔄 PortKillService deinit called")
        if !isDestroyed {
            // Use detached task to avoid capture warnings
            Task.detached { @MainActor [weak self] in
                self?.destroy()
            }
        }
    }
    
    private func killProcessByPID(_ pid: Int32) async throws {
        // First try SIGTERM (15)
        try await sendSignal(pid: pid, signal: 15)
        
        // Wait 500ms and check if process is still alive
        try await Task.sleep(nanoseconds: 500_000_000)
        
        if await isProcessRunning(pid) {
            // Send SIGKILL (9) if process is still alive
            try await sendSignal(pid: pid, signal: 9)
        }
    }
    
    private func sendSignal(pid: Int32, signal: Int32) async throws {
        let killProcess = Process()
        killProcess.executableURL = URL(fileURLWithPath: "/bin/kill")
        killProcess.arguments = ["-\(signal)", "\(pid)"]
        
        let errorPipe = Pipe()
        killProcess.standardError = errorPipe
        
        try killProcess.run()
        killProcess.waitUntilExit()
        
        guard killProcess.terminationStatus == 0 else {
            throw PortKillError.killFailed
        }
    }
    
    private func isProcessRunning(_ pid: Int32) async -> Bool {
        let psProcess = Process()
        psProcess.executableURL = URL(fileURLWithPath: "/bin/ps")
        psProcess.arguments = ["-p", "\(pid)"]
        psProcess.standardOutput = Pipe()
        psProcess.standardError = Pipe()
        
        do {
            try psProcess.run()
            psProcess.waitUntilExit()
            return psProcess.terminationStatus == 0
        } catch {
            return false
        }
    }
}
