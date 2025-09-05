import Foundation

// MARK: - StatusBarInfo Model
struct StatusBarInfo: Codable, Sendable {
    let text: String
    let tooltip: String
    let hasProcesses: Bool
    
    init(text: String, tooltip: String, hasProcesses: Bool) {
        self.text = text
        self.tooltip = tooltip
        self.hasProcesses = hasProcesses
    }
    
    // MARK: - Factory Methods
    
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
    
    static func scanning() -> StatusBarInfo {
        return StatusBarInfo(
            text: "Scanning...",
            tooltip: "Scanning for active processes on monitored ports",
            hasProcesses: false
        )
    }
    
    static var empty: StatusBarInfo {
        return fromProcessCount(0)
    }
}
