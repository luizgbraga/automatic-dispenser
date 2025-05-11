//
//  MedicineCompartment.swift
//  AutomaticDispenser
//
//  Created by Luiz Guilherme Amadi Braga on 08/05/25.
//

import Foundation

struct MedicineCompartment: Identifiable {
    var id = UUID()
    var number: Int
    var medicineName: String
    var schedule: MedicationSchedule?
    var pillCount: Int
    
    var isConfigured: Bool {
        return !medicineName.isEmpty && schedule != nil && pillCount > 0
    }
}
