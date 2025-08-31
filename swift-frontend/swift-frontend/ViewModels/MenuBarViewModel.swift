//
//  MenuBarViewModel.swift
//  swift-frontend
//
//  Created by Melih Özdemir on 31.08.2025.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class MenuBarViewModel: ObservableObject {
    @Published var processes: [ProcessInfo] = []
    @Published var isScanning: Bool = false
    @Published var statusInfo: StatusBarInfo = StatusBarInfo.fromProcessCount(0)
    @Published var showingError: Bool = false
    @Published var errorMessage: String = ""
    @Published var isKilling: Bool = false
    
    private let portKillService = PortKillService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
        // Don't start automatic monitoring - only scan manually
    }
    
    private func setupBindings() {
        // Bind service properties to view model
        portKillService.$processes
            .receive(on: DispatchQueue.main)
            .assign(to: \.processes, on: self)
            .store(in: &cancellables)
        
        portKillService.$isScanning
            .receive(on: DispatchQueue.main)
            .assign(to: \.isScanning, on: self)
            .store(in: &cancellables)
        
        portKillService.$statusInfo
            .receive(on: DispatchQueue.main)
            .assign(to: \.statusInfo, on: self)
            .store(in: &cancellables)
        
        portKillService.$lastError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    self?.showingError = true
                }
            }
            .store(in: &cancellables)
    }
    
    func startMonitoring() {
        // No longer auto-starting scan
    }
    
    func stopMonitoring() {
        portKillService.stopScanning()
    }
    
    func scanProcesses() async {
        await portKillService.manualScan()
    }
    
    func refreshProcesses() {
        Task {
            await scanProcesses()
        }
    }
    
    func killProcess(_ processInfo: ProcessInfo) {
        guard !isKilling else { return }
        
        isKilling = true
        
        Task {
            do {
                try await portKillService.killProcess(processInfo)
                await MainActor.run {
                    self.isKilling = false
                }
            } catch {
                await MainActor.run {
                    self.isKilling = false
                    self.errorMessage = "Failed to kill process: \(error.localizedDescription)"
                    self.showingError = true
                }
            }
        }
    }
    
    func killAllProcesses() {
        guard !isKilling else { return }
        guard !processes.isEmpty else { return }
        
        isKilling = true
        
        Task {
            do {
                try await portKillService.killAllProcesses()
                await MainActor.run {
                    self.isKilling = false
                }
            } catch {
                await MainActor.run {
                    self.isKilling = false
                    self.errorMessage = "Failed to kill all processes: \(error.localizedDescription)"
                    self.showingError = true
                }
            }
        }
    }
    
    var menuBarTitle: String {
        if isScanning {
            return "Scanning..."
        }
        return statusInfo.text
    }
    
    var menuBarIcon: String {
        if isScanning {
            return "wifi.circle"
        }
        return statusInfo.hasProcesses ? "circle.fill" : "circle"
    }
    
    deinit {
        Task { @MainActor in
            stopMonitoring()
        }
    }
}
