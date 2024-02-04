//
//  BluetoothError.swift
//  BluetoothScanner
//
//  Created by Subhankar Ghosh on 04/02/24.
//

import Foundation

enum BluetoothError {
    case bluetoothPoweredOff
    case bluetoothUnauthorized
    case bluetoothUnsupported
    case unknown
    
    var description: String {
        switch self {
        case .bluetoothPoweredOff:
            return "Please turn on bluetooth"
        case .bluetoothUnauthorized: 
            return "Allow bluetooth for connection"
        case .bluetoothUnsupported:
            return "Your phone does not support bluetooth"
        case .unknown:
            return "Unknown error"
        }
    }
}
