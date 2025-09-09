//
//  MenuBarViewModel.swift
//  swift-frontend
//
//  Created by Melih Özdemir on 31.08.2025.
//

import Foundation
import SwiftUI
import Combine

// MARK: - ViewModelError

enum ViewModelError: LocalizedError {
    case serviceUnavailable
    case operationCancelled
    case invalidState
    
    var errorDescription: String? {
        switch self {
        case .serviceUnavailable:
            return "Service is currently unavailable"
        case .operationCancelled:
            return "Operation was cancelled"
        case .invalidState:
            return "Invalid state for operation"
        }
    }
}

// MARK: - MenuBarViewModel

@MainActor
final class MenuBarViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published private(set) var processes: [ProcessInfo] = []
    @Published private(set) var isScanning: Bool = false
    @Published private(set) var statusInfo: StatusBarInfo = StatusBarInfo.fromProcessCount(0)
    @Published var showingError: Bool = false
    @Published var errorMessage: String = ""
    @Published private(set) var isKilling: Bool = false
    
    // MARK: - Private Properties
    
    private let portKillService: PortKillService
    private var cancellables = Set<AnyCancellable>()
    private var currentScanTask: Task<Void, Never>?
    private var currentKillTask: Task<Void, Never>?
    private var isDestroyed = false
    
    // MARK: - Initialization
    
    init(portKillService: PortKillService? = nil) {
        self.portKillService = portKillService ?? PortKillService()
        setupBindings()
        // Don't start automatic monitoring - only scan manually
    }
    
    // MARK: - Private Methods
    
    private func setupBindings() {
        // Bind service properties to view model with proper error handling
        portKillService.$processes
            .receive(on: DispatchQueue.main)
            .sink { [weak self] processes in
                guard let self = self, !self.isDestroyed else { return }
                self.processes = processes
            }
            .store(in: &cancellables)
        
        portKillService.$isScanning
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isScanning in
                guard let self = self, !self.isDestroyed else { return }
                self.isScanning = isScanning
            }
            .store(in: &cancellables)
        
        portKillService.$statusInfo
            .receive(on: DispatchQueue.main)
            .sink { [weak self] statusInfo in
                guard let self = self, !self.isDestroyed else { return }
                self.statusInfo = statusInfo
            }
            .store(in: &cancellables)
        
        portKillService.$lastError
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] error in
                guard let self = self, !self.isDestroyed else { return }
                self.handleError(error)
            }
            .store(in: &cancellables)
    }
    
    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        showingError = true
        
        // Log error for debugging
        print("❌ ViewModel Error: \(error)")
    }
    
    private func cancelCurrentTasks() {
        currentScanTask?.cancel()
        currentKillTask?.cancel()
        currentScanTask = nil
        currentKillTask = nil
    }
    
    // MARK: - Public Methods
    
    func startMonitoring() {
        // No longer auto-starting scan - keeping for interface compatibility
    }
    
    func stopMonitoring() {
        guard !isDestroyed else { return }
        cancelCurrentTasks()
        portKillService.stopScanning()
    }
    
    func scanProcesses() async throws {
        guard !isDestroyed else { 
            throw ViewModelError.invalidState
        }
        
        // Cancel any existing scan
        currentScanTask?.cancel()
        
        currentScanTask = Task {
            await portKillService.manualScan()
        }
        
        await currentScanTask?.value
        currentScanTask = nil
    }
    
    func refreshProcesses() {
        guard !isDestroyed else { return }
        
        // Cancel any existing operations
        cancelCurrentTasks()
        
        // Update monitored ports from settings before scanning
        portKillService.updateMonitoredPorts()
        
        currentScanTask = Task { [weak self] in
            guard let self = self else { return }
            do {
                try await self.scanProcesses()
            } catch {
                await MainActor.run {
                    self.handleError(error)
                }
            }
        }
    }
    
    func killProcess(_ processInfo: ProcessInfo) async {
        guard !isKilling && !isDestroyed else { return }
        
        // Cancel any existing kill task
        currentKillTask?.cancel()
        
        isKilling = true
        
        currentKillTask = Task { [weak self] in
            guard let self = self else { return }
            
            defer {
                Task { @MainActor in
                    guard !self.isDestroyed else { return }
                    self.isKilling = false
                }
            }
            
            do {
                try await self.portKillService.killProcess(processInfo)
            } catch {
                await MainActor.run {
                    guard !self.isDestroyed else { return }
                    self.handleError(error)
                }
            }
        }
        
        await currentKillTask?.value
        currentKillTask = nil
    }
    
    func killAllProcesses() async {
        guard !isKilling && !isDestroyed else { return }
        guard !processes.isEmpty else { return }
        
        // Cancel any existing kill task
        currentKillTask?.cancel()
        
        isKilling = true
        
        currentKillTask = Task { [weak self] in
            guard let self = self else { return }
            
            defer {
                Task { @MainActor in
                    guard !self.isDestroyed else { return }
                    self.isKilling = false
                }
            }
            
            do {
                try await self.portKillService.killAllProcesses()
            } catch {
                await MainActor.run {
                    guard !self.isDestroyed else { return }
                    self.handleError(error)
                }
            }
        }
        
        await currentKillTask?.value
        currentKillTask = nil
    }
    
    // MARK: - Computed Properties
    
    var menuBarTitle: String {
        if isScanning {
            return "Scanning..."
        }
        return statusInfo.text
    }
    
    var menuBarIcon: String {
        if isScanning {
            return "cpu"
        }
        return statusInfo.hasProcesses ? "cpu.fill" : "cpu"
    }
    
    // MARK: - Lifecycle
    
    func destroy() {
        guard !isDestroyed else { return }
        
        isDestroyed = true
        cancelCurrentTasks()
        stopMonitoring()
        cancellables.removeAll()
        
        print("✅ MenuBarViewModel destroyed")
    }
    
    deinit {
        print("🔄 MenuBarViewModel deinit called")
        if !isDestroyed {
            // Use detached task to avoid capture warnings
            Task.detached { @MainActor [weak self] in
                self?.destroy()
            }
        }
    }
}

