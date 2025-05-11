//
//  AlertsView.swift
//  AutomaticDispenser
//
//  Created by Luiz Guilherme Amadi Braga on 08/05/25.
//

import SwiftUI

struct AlertsView: View {
    @EnvironmentObject private var mockDataService: MockDataService
    
    var body: some View {
        NavigationView {
            VStack {
                if mockDataService.alerts.isEmpty {
                    emptyStateView
                } else {
                    alertsListView
                }
            }
            .navigationTitle("Medication Alerts")
            .background(Color.gray.opacity(0.1).ignoresSafeArea())
        }
    }
    
    private var alertsListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(mockDataService.alerts) { alert in
                    AlertItemView(alert: alert)
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
}

struct AlertItemView: View {
    let alert: MedicationEvent
    
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
                        // Mark as taken action
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
                        // Dismiss action
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
