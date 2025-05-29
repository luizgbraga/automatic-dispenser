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
    private var pollingTimer: Timer?
    private var lastPollTime: Date?
    
    init() {
        Task {
            await loadCurrentSchedule()
            startPolling()
        }
    }
    
    deinit {
        stopPolling()
    }
    
    private func startPolling() {
        pollingTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            Task {
                await self?.checkForDispensedPills()
            }
        }
    }
    
    private func stopPolling() {
        pollingTimer?.invalidate()
        pollingTimer = nil
    }
    
    private func checkForDispensedPills() async {
        do {
            let schedule = try await apiService.getCurrentSchedule()
            let currentTime = Date()

            for (index, item) in schedule.enumerated() {
                guard let compartment = compartments.first(where: { $0.number == index + 1 }) else { continue }
                
                let scheduledTime = DispenserDataService.createTime(hour: item.hour, minute: item.minute)
                
                if lastPollTime == nil || scheduledTime > lastPollTime! {
                    if scheduledTime <= currentTime {
                        let hasHistoryEntry = medicationHistory.contains { event in
                            event.compartmentNumber == compartment.number &&
                            Calendar.current.isDate(event.scheduledTime, inSameDayAs: scheduledTime) &&
                            Calendar.current.component(.hour, from: event.scheduledTime) == item.hour &&
                            Calendar.current.component(.minute, from: event.scheduledTime) == item.minute
                        }
                        
                        if !hasHistoryEntry {
                            let event = MedicationEvent(
                                compartmentNumber: compartment.number,
                                medicineName: compartment.medicineName,
                                scheduledTime: scheduledTime,
                                actualTime: nil,
                                status: .pending,
                                pillsTaken: item.pills
                            )
                            
                            await MainActor.run {
                                medicationHistory.append(event)
                                alerts.append(event)
                            }
                            
                            NotificationService.shared.scheduleNotification(for: event)
                        }
                    }
                }
            }
            
            await MainActor.run {
                lastPollTime = currentTime
            }
        } catch {
            print("Failed to check for dispensed pills: \(error)")
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
