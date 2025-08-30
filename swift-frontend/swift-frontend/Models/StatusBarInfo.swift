//
//  StatusBarInfo.swift
//  swift-frontend
//
//  Created by Melih Özdemir on 31.08.2025.
//

import Foundation

struct StatusBarInfo: Codable {
    let text: String
    let tooltip: String
    let hasProcesses: Bool
    
    init(text: String, tooltip: String, hasProcesses: Bool) {
        self.text = text
        self.tooltip = tooltip
        self.hasProcesses = hasProcesses
    }
    
    static func fromProcessCount(_ count: Int) -> StatusBarInfo {
        if count == 0 {
            return StatusBarInfo(
                text: "No Active Ports",
                tooltip: "No processes are currently listening on monitored ports",
                hasProcesses: false
            )
        } else {
            return StatusBarInfo(
                text: "\(count) Active Port\(count > 1 ? "s" : "")",
                tooltip: "\(count) process\(count > 1 ? "es" : "") found on monitored ports",
                hasProcesses: true
            )
        }
    }
}
