//
//  MedicationEvent.swift
//  AutomaticDispenser
//
//  Created by Luiz Guilherme Amadi Braga on 08/05/25.
//

import Foundation

enum MedicationStatus: String {
    case taken = "Taken"
    case missed = "Missed"
    case pending = "Pending"
}

struct MedicationEvent: Identifiable {
    var id = UUID()
    var compartmentNumber: Int
    var medicineName: String
    var scheduledTime: Date
    var actualTime: Date?
    var status: MedicationStatus
    var pillsTaken: Int
    
    var formattedScheduledTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: scheduledTime)
    }
    
    var formattedActualTime: String? {
        guard let actualTime = actualTime else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: actualTime)
    }
}
