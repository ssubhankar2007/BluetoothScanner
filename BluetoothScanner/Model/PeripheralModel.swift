//
//  PeripheralData.swift
//  BluetoothScanner
//
//  Created by Subhankar Ghosh on 05/02/24.
//

import Foundation
import CoreBluetooth

class PeripheralModel: Identifiable {
    let id: CBUUID
    
    init(id: CBUUID) {
        self.id = id
    }
    
    var children: [PeripheralModel]? = nil
}

extension PeripheralModel: Equatable {
    static func == (lhs: PeripheralModel, rhs: PeripheralModel) -> Bool {
        return lhs.id == rhs.id
    }
}
