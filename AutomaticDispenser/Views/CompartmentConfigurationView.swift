//
//  CompartmentConfigurationView.swift
//  AutomaticDispenser
//
//  Created by Luiz Guilherme Amadi Braga on 08/05/25.
//

import SwiftUI

struct CompartmentConfigurationView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var compartment: MedicineCompartment
    @State private var frequencyType: FrequencyType = .daily
    @State private var timesPerDay: Int = 1
    @State private var specificTimes: [Date] = [Date()]
    
    let onSave: (MedicineCompartment) -> Void
    
    init(compartment: MedicineCompartment, onSave: @escaping (MedicineCompartment) -> Void) {
        _compartment = State(initialValue: compartment)
        
        if let schedule = compartment.schedule {
            _frequencyType = State(initialValue: schedule.frequencyType)
            _timesPerDay = State(initialValue: schedule.timesPerDay)
            _specificTimes = State(initialValue: schedule.specificTimes.isEmpty ? [Date()] : schedule.specificTimes)
        }
        
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Compartment Details")) {
                    Text("Compartment \(compartment.number)")
                        .font(.headline)
                    
                    TextField("Medicine Name", text: $compartment.medicineName)
                    
                    Stepper("Pills: \(compartment.pillCount)", value: $compartment.pillCount, in: 0...100)
                }
                
                Section(header: Text("Schedule")) {
                    Picker("Frequency", selection: $frequencyType) {
                        ForEach(FrequencyType.allCases) { frequency in
                            Text(frequency.rawValue)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    if frequencyType == .daily {
                        Stepper("Times per day: \(timesPerDay)", value: $timesPerDay, in: 1...5)
                    } else {
                        ForEach(0..<specificTimes.count, id: \.self) { index in
                            HStack {
                                DatePicker("Time \(index + 1)", selection: $specificTimes[index], displayedComponents: .hourAndMinute)
                                
                                if specificTimes.count > 1 {
                                    Button(action: {
                                        specificTimes.remove(at: index)
                                    }) {
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                        }
                        
                        Button(action: {
                            specificTimes.append(Date())
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Time")
                            }
                        }
                    }
                }
                
                if compartment.isConfigured {
                    Section {
                        Button("Test Dispense") {
                            // Mock a dispense test
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("Configure Medicine")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveCompartment()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(compartment.medicineName.isEmpty)
                }
            }
        }
    }
    
    private func saveCompartment() {
        var schedule: MedicationSchedule
        
        if frequencyType == .daily {
            schedule = MedicationSchedule(
                frequencyType: .daily,
                timesPerDay: timesPerDay
            )
        } else {
            schedule = MedicationSchedule(
                frequencyType: .specificTimes,
                specificTimes: specificTimes
            )
        }
        
        compartment.schedule = schedule
        onSave(compartment)
    }
}
