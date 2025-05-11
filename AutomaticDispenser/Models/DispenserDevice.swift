//
//  DispenserDevice.swift
//  AutomaticDispenser
//
//  Created by Luiz Guilherme Amadi Braga on 08/05/25.
//

import Foundation

struct DispenserDevice: Identifiable, Equatable {
    var id = UUID()
    var name: String
    var ipAddress: String
    var isConnected: Bool = false
    
    static func == (lhs: DispenserDevice, rhs: DispenserDevice) -> Bool {
        return lhs.id == rhs.id
    }
}
