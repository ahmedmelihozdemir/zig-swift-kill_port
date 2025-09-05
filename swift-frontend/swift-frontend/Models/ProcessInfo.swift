import Foundation

// MARK: - ProcessInfo Model
struct ProcessInfo: Identifiable, Codable, Hashable, Sendable {
    let id = UUID()
    let pid: Int32
    let port: UInt16
    let command: String
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case pid, port, command, name
    }
    
    init(pid: Int32, port: UInt16, command: String, name: String) {
        self.pid = pid
        self.port = port
        self.command = command
        self.name = name
    }
    
    // MARK: - Computed Properties
    
    /// Display name with port information
    var displayName: String {
        return "\(name) (\(port))"
    }
    
    /// Short description for tooltip
    var shortDescription: String {
        return "PID: \(pid), Port: \(port), Process: \(name)"
    }
    
    // MARK: - Static Methods
    
    /// Create a sample ProcessInfo for previews
    static var sample: ProcessInfo {
        ProcessInfo(pid: 12345, port: 3000, command: "/usr/bin/node", name: "node")
    }
}

// MARK: - ProcessUpdate Model
struct ProcessUpdate: Codable, Sendable {
    let processes: [UInt16: ProcessInfo]
    let count: Int
    
    var processesArray: [ProcessInfo] {
        return Array(processes.values).sorted { $0.port < $1.port }
    }
    
    static var empty: ProcessUpdate {
        ProcessUpdate(processes: [:], count: 0)
    }
}
