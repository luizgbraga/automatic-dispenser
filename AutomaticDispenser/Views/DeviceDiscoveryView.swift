//
//  DeviceDiscoveryView.swift
//  AutomaticDispenser
//
//  Created by Luiz Guilherme Amadi Braga on 08/05/25.
//

import SwiftUI

struct DeviceDiscoveryView: View {
    @EnvironmentObject private var connectionService: DispenserConnectionService
    
    var body: some View {
        NavigationView {
            VStack {
                headerView
                
                if connectionService.isSearching {
                    searchingView
                } else if !connectionService.discoveredDevices.isEmpty {
                    deviceListView
                } else {
                    emptyStateView
                }
                
                Spacer()
                
                searchButton
            }
            .padding()
            .navigationTitle("Connect Device")
            .background(Color.gray.opacity(0.1).ignoresSafeArea())
        }
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Automatic Medicine Dispenser")
                .font(.headline)
                .foregroundColor(.secondary)
            
            if let device = connectionService.connectedDevice {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Connected to: \(device.name)")
                        .fontWeight(.medium)
                    Spacer()
                    Button(action: {
                        connectionService.disconnectFromDevice()
                    }) {
                        Text("Disconnect")
                            .foregroundColor(.red)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            }
        }
        .padding(.bottom)
    }
    
    private var searchingView: some View {
        VStack {
            Spacer()
            ProgressView()
                .scaleEffect(1.5)
                .padding()
            Text("Searching for nearby devices...")
                .foregroundColor(.secondary)
            Spacer()
        }
    }
    
    private var deviceListView: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(connectionService.discoveredDevices) { device in
                    DeviceItemView(device: device) {
                        connectionService.connectToDevice(device)
                    }
                }
            }
            .padding(.vertical)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "wifi.slash")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("No devices found")
                .font(.title3)
                .fontWeight(.medium)
            Text("Tap the search button to find nearby medicine dispensers")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Spacer()
        }
    }
    
    private var searchButton: some View {
        Button(action: {
            connectionService.searchForDevices()
        }) {
            HStack {
                Image(systemName: "magnifyingglass")
                Text("Search for Devices")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .shadow(color: Color.blue.opacity(0.3), radius: 5, x: 0, y: 2)
        }
        .disabled(connectionService.isSearching)
    }
}

struct DeviceItemView: View {
    let device: DispenserDevice
    let onConnect: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(device.name)
                    .font(.headline)
                Text(device.ipAddress)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if device.isConnected {
                Label("Connected", systemImage: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.subheadline)
            } else {
                Button("Connect") {
                    onConnect()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
