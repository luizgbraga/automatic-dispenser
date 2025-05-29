//
//  DispenserConnectionService.swift
//  AutomaticDispenser
//
//  Created by Luiz Guilherme Amadi Braga on 08/05/25.
//

import Foundation
import Combine

class DispenserConnectionService: ObservableObject {
    @Published var discoveredDevices: [DispenserDevice] = []
    @Published var connectedDevice: DispenserDevice?
    @Published var isSearching = false
    @Published var errorMessage: String?
    
    private let apiService = APIService.shared
    
    func searchForDevices() {
        isSearching = true
        errorMessage = nil
        
        Task {
            do {
                let deviceInfo = try await apiService.getDeviceInfo()
                await MainActor.run {
                    let device = DispenserDevice(
                        name: deviceInfo.device_name,
                        ipAddress: deviceInfo.ap_ip,
                    )
                    self.discoveredDevices = [device]
                    self.isSearching = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to discover devices: \(error.localizedDescription)"
                    self.isSearching = false
                }
            }
        }
    }
    
    func connectToDevice(_ device: DispenserDevice) {
        isSearching = true
        
        Task {
            do {
                let deviceInfo = try await apiService.getDeviceInfo()
                await MainActor.run {
                    var updatedDevice = device
                    updatedDevice.isConnected = true
                    self.connectedDevice = updatedDevice
                    
                    if let index = self.discoveredDevices.firstIndex(where: { $0.id == device.id }) {
                        self.discoveredDevices[index].isConnected = true
                    }
                    
                    self.isSearching = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to connect to device: \(error.localizedDescription)"
                    self.isSearching = false
                }
            }
        }
    }
    
    func disconnectFromDevice() {
        guard connectedDevice != nil else { return }
        
        Task {
            await MainActor.run {
                if let connectedDevice = self.connectedDevice,
                   let index = self.discoveredDevices.firstIndex(where: { $0.id == connectedDevice.id }) {
                    self.discoveredDevices[index].isConnected = false
                }
                self.connectedDevice = nil
            }
        }
    }
    
    func configureWiFi(ssid: String, password: String, timezoneOffset: Int) async throws {
        try await apiService.configureWiFi(ssid: ssid, password: password, timezoneOffset: timezoneOffset)
    }
    
    func setPillSchedule(schedule: [PillScheduleItem]) async throws {
        try await apiService.setPillSchedule(schedule: schedule)
    }
    
    func getCurrentSchedule() async throws -> [PillScheduleItem] {
        return try await apiService.getCurrentSchedule()
    }
    
    func dispensePills(count: Int) async throws {
        try await apiService.dispensePills(count: count)
    }
}
