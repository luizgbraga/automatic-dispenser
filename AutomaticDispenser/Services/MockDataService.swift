//
//  MockDataService.swift
//  AutomaticDispenser
//
//  Created by Luiz Guilherme Amadi Braga on 08/05/25.
//

import Foundation
import Combine

class DispenserDataService: ObservableObject {
    @Published var compartments: [MedicineCompartment] = []
    @Published var medicationHistory: [MedicationEvent] = []
    @Published var alerts: [MedicationEvent] = []
    
    private let apiService = APIService.shared
    
    init() {
        Task {
            await loadCurrentSchedule()
        }
    }
    
    private func loadCurrentSchedule() async {
        do {
            let schedule = try await apiService.getCurrentSchedule()
            await MainActor.run {
                self.compartments = schedule.enumerated().map { index, item in
                    MedicineCompartment(
                        number: index + 1,
                        medicineName: "Medicine \(index + 1)",
                        schedule: MedicationSchedule(
                            frequencyType: .specificTimes,
                            specificTimes: [DispenserDataService.createTime(hour: item.hour, minute: item.minute)]
                        ),
                        pillCount: item.pills
                    )
                }
            }
        } catch {
            print("Failed to load schedule: \(error)")
        }
    }
    
    func updateCompartment(_ compartment: MedicineCompartment) async throws {
        guard let schedule = compartment.schedule else { return }
        
        let scheduleItems = schedule.specificTimes.map { time in
            let components = Calendar.current.dateComponents([.hour, .minute], from: time)
            return PillScheduleItem(
                hour: components.hour ?? 0,
                minute: components.minute ?? 0,
                pills: compartment.pillCount
            )
        }
        
        try await apiService.setPillSchedule(schedule: scheduleItems)
        
        await MainActor.run {
            if let index = compartments.firstIndex(where: { $0.id == compartment.id }) {
                compartments[index] = compartment
            }
        }
    }
    
    func dispensePills(from compartment: MedicineCompartment) async throws {
        try await apiService.dispensePills(count: compartment.pillCount)
        
        await MainActor.run {
            if let index = compartments.firstIndex(where: { $0.id == compartment.id }) {
                var updatedCompartment = compartment
                updatedCompartment.pillCount -= 1
                compartments[index] = updatedCompartment
                
                let event = MedicationEvent(
                    compartmentNumber: compartment.number,
                    medicineName: compartment.medicineName,
                    scheduledTime: Date(),
                    actualTime: Date(),
                    status: .taken,
                    pillsTaken: 1
                )
                medicationHistory.append(event)
            }
        }
    }
    
    private static func createTime(hour: Int, minute: Int) -> Date {
        let calendar = Calendar.current
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: Date()) ?? Date()
    }
}
