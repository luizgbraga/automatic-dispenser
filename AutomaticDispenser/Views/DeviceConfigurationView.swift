//
//  DeviceConfigurationView.swift
//  AutomaticDispenser
//
//  Created by Luiz Guilherme Amadi Braga on 08/05/25.
//
import SwiftUI

struct DeviceConfigurationView: View {
    @EnvironmentObject private var connectionService: DispenserConnectionService
    @EnvironmentObject private var dataService: DispenserDataService
    
    @State private var selectedCompartment: MedicineCompartment?
    @State private var showingCompartmentConfig = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            ScrollView {
                if let device = connectionService.connectedDevice {
                    VStack(alignment: .leading, spacing: 20) {
                        deviceInfoView(device)
                        compartmentsGridView
                    }
                    .padding()
                } else {
                    notConnectedView
                }
            }
            .navigationTitle("Configure Dispenser")
            .background(Color.gray.opacity(0.1).ignoresSafeArea())
            .sheet(isPresented: $showingCompartmentConfig) {
                if let compartment = selectedCompartment {
                    CompartmentConfigurationView(
                        compartment: compartment,
                        onSave: { updatedCompartment in
                            Task {
                                do {
                                    try await dataService.updateCompartment(updatedCompartment)
                                    await MainActor.run {
                                        selectedCompartment = nil
                                    }
                                } catch {
                                    await MainActor.run {
                                        errorMessage = "Failed to update compartment: \(error.localizedDescription)"
                                    }
                                }
                            }
                        }
                    )
                }
            }
            .overlay {
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") {
                    errorMessage = nil
                }
            } message: {
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                }
            }
        }
    }
    
    private func deviceInfoView(_ device: DispenserDevice) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(device.name)
                .font(.title2)
                .fontWeight(.bold)
            
            Text("IP Address: \(device.ipAddress)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Divider()
                .padding(.vertical, 4)
            
            Text("Compartment Configuration")
                .font(.headline)
                .padding(.top, 4)
        }
    }
    
    private var compartmentsGridView: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
            ForEach(dataService.compartments) { compartment in
                CompartmentItemView(compartment: compartment)
                    .onTapGesture {
                        selectedCompartment = compartment
                        showingCompartmentConfig = true
                    }
            }
        }
    }
    
    private var notConnectedView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("Not Connected")
                .font(.title3)
                .fontWeight(.medium)
            
            Text("Please connect to a medicine dispenser first")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            NavigationLink(destination: DeviceDiscoveryView()) {
                HStack {
                    Image(systemName: "wifi")
                    Text("Go to Connect")
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding(.top)
            
            Spacer()
        }
        .padding()
    }
}

struct CompartmentItemView: View {
    let compartment: MedicineCompartment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Compartment \(compartment.number)")
                    .font(.headline)
                Spacer()
                Circle()
                    .fill(compartment.isConfigured ? Color.green : Color.gray)
                    .frame(width: 12, height: 12)
            }
            
            if compartment.isConfigured {
                Text(compartment.medicineName)
                    .font(.subheadline)
                    .lineLimit(1)
                
                if let schedule = compartment.schedule {
                    Text(schedule.displayText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("\(compartment.pillCount) pills")
                        .font(.caption)
                        .padding(4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(4)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                Text("Not configured")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                HStack {
                    Spacer()
                    Text("Configure")
                        .font(.caption)
                        .foregroundColor(.blue)
                    Image(systemName: "plus.circle")
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .frame(height: 130)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
