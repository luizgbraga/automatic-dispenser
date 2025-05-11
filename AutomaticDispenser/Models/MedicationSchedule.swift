//
//  MedicationSchedule.swift
//  AutomaticDispenser
//
//  Created by Luiz Guilherme Amadi Braga on 08/05/25.
//

import Foundation

enum FrequencyType: String, CaseIterable, Identifiable {
    case daily = "Daily"
    case specificTimes = "Specific Times"
    
    var id: String { self.rawValue }
}

struct MedicationSchedule: Identifiable {
    var id = UUID()
    var frequencyType: FrequencyType
    var timesPerDay: Int = 1
    var specificTimes: [Date] = []
    
    var displayText: String {
        switch frequencyType {
        case .daily:
            return timesPerDay == 1 ? "Once a day" : "\(timesPerDay)x a day"
        case .specificTimes:
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return specificTimes.map { formatter.string(from: $0) }.joined(separator: ", ")
        }
    }
}
