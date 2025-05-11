//
//  MockDataService.swift
//  AutomaticDispenser
//
//  Created by Luiz Guilherme Amadi Braga on 08/05/25.
//

import Foundation
import Combine

class MockDataService: ObservableObject {
    @Published var compartments: [MedicineCompartment] = []
    @Published var medicationHistory: [MedicationEvent] = []
    @Published var alerts: [MedicationEvent] = []
    
    init() {
        setupMockData()
    }
    
    private func setupMockData() {
        // Create mock compartments
        compartments = (1...7).map { number in
            if number <= 3 {
                // Pre-configure a few compartments
                return MedicineCompartment(
                    number: number,
                    medicineName: mockMedicineNames[number - 1],
                    schedule: mockSchedules[number - 1],
                    pillCount: Int.random(in: 5...20)
                )
            } else {
                // Leave others unconfigured
                return MedicineCompartment(
                    number: number,
                    medicineName: "",
                    schedule: nil,
                    pillCount: 0
                )
            }
        }
        
        // Create mock history
        let calendar = Calendar.current
        let today = Date()
        
        // Generate history for the last 7 days
        for day in 0..<7 {
            let date = calendar.date(byAdding: .day, value: -day, to: today)!
            
            // For each configured compartment, create history entries
            for compartment in compartments where compartment.isConfigured {
                guard let schedule = compartment.schedule else { continue }
                
                switch schedule.frequencyType {
                case .daily:
                    // Generate entries for each time per day
                    for time in 0..<schedule.timesPerDay {
                        let hour = 8 + (time * 4) // 8am, 12pm, 4pm, etc.
                        if let scheduledTime = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: date) {
                            // Randomly decide if medication was taken or missed
                            let status = Bool.random() ? MedicationStatus.taken : MedicationStatus.missed
                            let actualTime = status == .taken ? calendar.date(byAdding: .minute, value: Int.random(in: 0...30), to: scheduledTime) : nil
                            
                            let event = MedicationEvent(
                                compartmentNumber: compartment.number,
                                medicineName: compartment.medicineName,
                                scheduledTime: scheduledTime,
                                actualTime: actualTime,
                                status: status,
                                pillsTaken: status == .taken ? 1 : 0
                            )
                            
                            medicationHistory.append(event)
                            
                            // Add to alerts if it was missed and within the last 2 days
                            if status == .missed && day < 2 {
                                alerts.append(event)
                            }
                        }
                    }
                    
                case .specificTimes:
                    // Generate entries for specific times
                    for specificTime in schedule.specificTimes {
                        let components = calendar.dateComponents([.hour, .minute], from: specificTime)
                        if let scheduledTime = calendar.date(bySettingHour: components.hour ?? 8, minute: components.minute ?? 0, second: 0, of: date) {
                            // Randomly decide if medication was taken or missed
                            let status = Bool.random() ? MedicationStatus.taken : MedicationStatus.missed
                            let actualTime = status == .taken ? calendar.date(byAdding: .minute, value: Int.random(in: 0...30), to: scheduledTime) : nil
                            
                            let event = MedicationEvent(
                                compartmentNumber: compartment.number,
                                medicineName: compartment.medicineName,
                                scheduledTime: scheduledTime,
                                actualTime: actualTime,
                                status: status,
                                pillsTaken: status == .taken ? 1 : 0
                            )
                            
                            medicationHistory.append(event)
                            
                            // Add to alerts if it was missed and within the last 2 days
                            if status == .missed && day < 2 {
                                alerts.append(event)
                            }
                        }
                    }
                }
            }
        }
        
        // Sort history by date (most recent first)
        medicationHistory.sort { $0.scheduledTime > $1.scheduledTime }
        
        // Sort alerts by date (most recent first)
        alerts.sort { $0.scheduledTime > $1.scheduledTime }
    }
    
    // Mock data
    private let mockMedicineNames = [
        "Aspirin",
        "Vitamin D",
        "Blood Pressure Medication"
    ]
    
    private let mockSchedules = [
        MedicationSchedule(frequencyType: .daily, timesPerDay: 2),
        MedicationSchedule(
            frequencyType: .specificTimes,
            specificTimes: [
                createTime(hour: 8, minute: 0),
                createTime(hour: 20, minute: 0)
            ]
        ),
        MedicationSchedule(frequencyType: .daily, timesPerDay: 3)
    ]
    
    private static func createTime(hour: Int, minute: Int) -> Date {
        let calendar = Calendar.current
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) ?? Date()
    }
    
    func updateCompartment(_ compartment: MedicineCompartment) {
        if let index = compartments.firstIndex(where: { $0.id == compartment.id }) {
            compartments[index] = compartment
        }
    }
}
