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
    
    func searchForDevices() {
        isSearching = true
        errorMessage = nil
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self = self else { return }
            
            // Mock found devices
            self.discoveredDevices = [
                DispenserDevice(name: "MedDispenser-Kitchen", ipAddress: "192.168.1.100"),
                DispenserDevice(name: "MedDispenser-Bedroom", ipAddress: "192.168.1.101"),
                DispenserDevice(name: "MedDispenser-Livingroom", ipAddress: "192.168.1.102")
            ]
            
            self.isSearching = false
        }
    }
    
    func connectToDevice(_ device: DispenserDevice) {
        isSearching = true
        
        // Simulate connection delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            
            // Update the connected device with connected status
            var updatedDevice = device
            updatedDevice.isConnected = true
            self.connectedDevice = updatedDevice
            
            // Update the discovered devices list
            if let index = self.discoveredDevices.firstIndex(where: { $0.id == device.id }) {
                self.discoveredDevices[index].isConnected = true
            }
            
            self.isSearching = false
        }
    }
    
    func disconnectFromDevice() {
        guard connectedDevice != nil else { return }
        
        // Simulate disconnection delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            // Update the discovered devices list
            if let connectedDevice = self.connectedDevice,
               let index = self.discoveredDevices.firstIndex(where: { $0.id == connectedDevice.id }) {
                self.discoveredDevices[index].isConnected = false
            }
            
            self.connectedDevice = nil
        }
    }
}
