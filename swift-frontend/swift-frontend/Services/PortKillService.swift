//
//  PortKillService.swift
//  swift-frontend
//
//  Created by Melih Özdemir on 31.08.2025.
//

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
class PortKillService: ObservableObject {
    @Published var processes: [ProcessInfo] = []
    @Published var isScanning: Bool = false
    @Published var lastError: PortKillError?
    @Published var statusInfo: StatusBarInfo = StatusBarInfo.fromProcessCount(0)
    
    private var scanTimer: Timer?
    private let backendPath: String
    private let monitoredPorts: [UInt16]
    
    init(backendPath: String = "", monitoredPorts: [UInt16] = [3000, 3001, 8000, 8080, 5000, 9000]) {
        self.monitoredPorts = monitoredPorts
        
        if backendPath.isEmpty {
            self.backendPath = Self.findBackendExecutable()
        } else {
            self.backendPath = backendPath
        }
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
    
    func startScanning() {
        guard scanTimer == nil else { return }
        
        scanTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            Task {
                await self?.scanProcesses()
            }
        }
        
        // Initial scan
        Task {
            await scanProcesses()
        }
    }
    
    func stopScanning() {
        scanTimer?.invalidate()
        scanTimer = nil
        isScanning = false
    }
    
    func scanProcesses() async {
        isScanning = true
        lastError = nil
        
        NSLog("🔍 DEBUG: scanProcesses() called - monitoring ports: \(monitoredPorts)")
        print("📡 Scanning ports: \(monitoredPorts)")
        
        do {
            let newProcesses = try await scanPortsDirectly()
            
            NSLog("🔍 DEBUG: scanPortsDirectly() returned \(newProcesses.count) processes")
            print("✅ Found \(newProcesses.count) processes")
            for process in newProcesses {
                print("   Port \(process.port): \(process.name) (PID: \(process.pid))")
            }
            
            await MainActor.run {
                self.processes = newProcesses
                self.statusInfo = StatusBarInfo.fromProcessCount(newProcesses.count)
                self.isScanning = false
            }
        } catch let error as PortKillError {
            print("❌ PortKill error: \(error.localizedDescription)")
            await MainActor.run {
                self.lastError = error
                self.isScanning = false
            }
        } catch {
            print("❌ General error: \(error)")
            await MainActor.run {
                self.lastError = .commandFailed
                self.isScanning = false
            }
        }
    }
    
    private func scanPortsDirectly() async throws -> [ProcessInfo] {
        var foundProcesses: [ProcessInfo] = []
        
        for port in monitoredPorts {
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
        // Use lsof to find processes listening on the port (both IPv4 and IPv6)
        NSLog("🔍 DEBUG: Checking port \(port)")
        print("🔍 Checking port \(port)")
        
        let lsofProcess = Process()
        lsofProcess.executableURL = URL(fileURLWithPath: "/usr/sbin/lsof")
        lsofProcess.arguments = ["-i", ":\(port)", "-sTCP:LISTEN"]
        
        let pipe = Pipe()
        lsofProcess.standardOutput = pipe
        lsofProcess.standardError = Pipe()
        
        try lsofProcess.run()
        lsofProcess.waitUntilExit()
        
        guard lsofProcess.terminationStatus == 0 else {
            print("❌ lsof failed for port \(port)")
            throw PortKillError.processNotFound
        }
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        NSLog("🔍 DEBUG: lsof output for port \(port): '\(output)'")
        print("📝 lsof output for port \(port): '\(output)'")
        
        guard !output.isEmpty else {
            print("❌ Empty lsof output for port \(port)")
            throw PortKillError.processNotFound
        }
        
        // Parse lsof output to extract PID
        // Output format: COMMAND  PID USER   FD   TYPE    DEVICE SIZE/OFF NODE NAME
        let lines = output.components(separatedBy: .newlines)
        guard lines.count > 1 else { // Skip header line
            print("❌ Not enough lines in lsof output for port \(port)")
            throw PortKillError.processNotFound
        }
        
        // Get the first data line (skip header)
        let processLine = lines[1]
        print("📋 Process line: '\(processLine)'")
        let components = processLine.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        print("📋 Components: \(components)")
        
        guard components.count >= 2, let pid = Int32(components[1]) else {
            print("❌ Could not parse PID from components for port \(port)")
            throw PortKillError.parseError
        }
        
        print("✅ Found PID \(pid) for port \(port)")
        
        // Get process details
        let processInfo = try await getProcessDetails(pid: pid, port: port)
        return processInfo
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
        try await killProcessByPID(processInfo.pid)
        
        // Refresh the process list after killing
        await scanProcesses()
    }
    
    func killAllProcesses() async throws {
        for processInfo in processes {
            try await killProcessByPID(processInfo.pid)
        }
        
        // Refresh the process list after killing all
        await scanProcesses()
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
