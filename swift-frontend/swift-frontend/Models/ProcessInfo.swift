//
//  ProcessInfo.swift
//  swift-frontend
//
//  Created by Melih Özdemir on 31.08.2025.
//

import Foundation

struct ProcessInfo: Identifiable, Codable, Hashable {
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
}

struct ProcessUpdate: Codable {
    let processes: [UInt16: ProcessInfo]
    let count: Int
    
    var processesArray: [ProcessInfo] {
        return Array(processes.values).sorted { $0.port < $1.port }
    }
}
