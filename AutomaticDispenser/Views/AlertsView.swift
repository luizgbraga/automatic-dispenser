//
//  AlertsView.swift
//  AutomaticDispenser
//
//  Created by Luiz Guilherme Amadi Braga on 08/05/25.
//

import SwiftUI

struct AlertsView: View {
    @EnvironmentObject private var dataService: DispenserDataService
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            VStack {
                if dataService.alerts.isEmpty {
                    emptyStateView
                } else {
                    alertsListView
                }
            }
            .navigationTitle("Medication Alerts")
            .background(Color.gray.opacity(0.1).ignoresSafeArea())
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
    
    private var alertsListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(dataService.alerts) { alert in
                    AlertItemView(alert: alert) { action in
                        Task {
                            await handleAlertAction(alert, action: action)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "bell.slash")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No alerts")
                .font(.title3)
                .fontWeight(.medium)
            
            Text("You're all caught up!")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding()
    }
    
    private func handleAlertAction(_ alert: MedicationEvent, action: AlertAction) async {
        await MainActor.run { isLoading = true }
        
        do {
            switch action {
            case .markAsTaken:
                // Find the corresponding compartment
                if let compartment = dataService.compartments.first(where: { $0.number == alert.compartmentNumber }) {
                    try await dataService.dispensePills(from: compartment)
                }
            case .dismiss:
                // Remove from alerts
                await MainActor.run {
                    if let index = dataService.alerts.firstIndex(where: { $0.id == alert.id }) {
                        dataService.alerts.remove(at: index)
                    }
                }
            }
        } catch {
            await MainActor.run {
                errorMessage = "Failed to handle alert: \(error.localizedDescription)"
            }
        }
        
        await MainActor.run { isLoading = false }
    }
}

enum AlertAction {
    case markAsTaken
    case dismiss
}

struct AlertItemView: View {
    let alert: MedicationEvent
    let onAction: (AlertAction) -> Void
    
    var body: some View {
        HStack(spacing: 15) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    
                    Text("Missed Medication")
                        .font(.headline)
                        .foregroundColor(.red)
                }
                
                Text(alert.medicineName)
                    .font(.title3)
                    .fontWeight(.medium)
                
                Text("Compartment \(alert.compartmentNumber)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Scheduled: \(alert.formattedScheduledTime)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Spacer()
                    
                    Button(action: {
                        onAction(.markAsTaken)
                    }) {
                        Text("Mark as Taken")
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        onAction(.dismiss)
                    }) {
                        Text("Dismiss")
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.primary)
                            .cornerRadius(8)
                    }
                }
                .padding(.top, 4)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.orange, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
}
