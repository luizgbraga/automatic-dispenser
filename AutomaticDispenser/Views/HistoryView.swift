//
//  HistoryView.swift
//  AutomaticDispenser
//
//  Created by Luiz Guilherme Amadi Braga on 08/05/25.
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var dataService: DispenserDataService
    @State private var selectedFilter: HistoryFilter = .all
    @State private var searchText = ""
    
    var filteredHistory: [MedicationEvent] {
        let filtered = dataService.medicationHistory.filter { event in
            switch selectedFilter {
            case .all: return true
            case .taken: return event.status == .taken
            case .missed: return event.status == .missed
            }
        }
        
        if searchText.isEmpty {
            return filtered
        } else {
            return filtered.filter { event in
                event.medicineName.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    var groupedHistory: [String: [MedicationEvent]] {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        
        var result = [String: [MedicationEvent]]()
        
        for event in filteredHistory {
            let dateString = formatter.string(from: event.scheduledTime)
            if result[dateString] == nil {
                result[dateString] = [event]
            } else {
                result[dateString]?.append(event)
            }
        }
        
        return result
    }
    
    var body: some View {
        NavigationView {
            VStack {
                filterSegmentControl
                
                if filteredHistory.isEmpty {
                    emptyStateView
                } else {
                    historyListView
                }
            }
            .searchable(text: $searchText, prompt: "Search medications")
            .navigationTitle("Medication History")
            .background(Color.gray.opacity(0.1).ignoresSafeArea())
        }
    }
    
    private var filterSegmentControl: some View {
        Picker("Filter", selection: $selectedFilter) {
            ForEach(HistoryFilter.allCases) { filter in
                Text(filter.displayText).tag(filter)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    private var historyListView: some View {
        ScrollView {
            LazyVStack(spacing: 16, pinnedViews: [.sectionHeaders]) {
                ForEach(groupedHistory.keys.sorted(by: >), id: \.self) { date in
                    Section(header: sectionHeader(for: date)) {
                        ForEach(groupedHistory[date] ?? []) { event in
                            HistoryItemView(event: event)
                                .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
    }
    
    private func sectionHeader(for date: String) -> some View {
        HStack {
            Text(date)
                .font(.headline)
                .padding(.leading)
                .padding(.vertical, 8)
            Spacer()
        }
        .background(Color.gray.opacity(0.1).opacity(0.95))
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No history found")
                .font(.title3)
                .fontWeight(.medium)
            
            if !searchText.isEmpty {
                Text("Try a different search term")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                Text("Your medication history will appear here")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
    }
}

struct HistoryItemView: View {
    let event: MedicationEvent
    
    var body: some View {
        HStack(spacing: 15) {
            statusIndicator
            
            VStack(alignment: .leading, spacing: 4) {
                Text(event.medicineName)
                    .font(.headline)
                
                Text("Compartment \(event.compartmentNumber)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Label("Scheduled: \(event.formattedScheduledTime)", systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let actualTime = event.formattedActualTime {
                        Spacer()
                        Label("Taken: \(actualTime)", systemImage: "checkmark.circle")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var statusIndicator: some View {
        ZStack {
            Circle()
                .fill(statusColor)
                .frame(width: 40, height: 40)
            
            Image(systemName: statusIcon)
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .bold))
        }
    }
    
    private var statusColor: Color {
        switch event.status {
        case .taken: return .green
        case .missed: return .red
        case .pending: return .orange
        }
    }
    
    private var statusIcon: String {
        switch event.status {
        case .taken: return "checkmark"
        case .missed: return "xmark"
        case .pending: return "clock"
        }
    }
}

enum HistoryFilter: String, CaseIterable, Identifiable {
    case all
    case taken
    case missed
    
    var id: String { self.rawValue }
    
    var displayText: String {
        switch self {
        case .all: return "All"
        case .taken: return "Taken"
        case .missed: return "Missed"
        }
    }
}
