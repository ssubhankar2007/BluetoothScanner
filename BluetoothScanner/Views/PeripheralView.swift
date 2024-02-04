//
//  PeripheralView.swift
//  BluetoothScanner
//
//  Created by Subhankar Ghosh on 05/02/24.
//

import SwiftUI

struct PeripheralView : View {
    @ObservedObject var peripheral: PeripheralManager
    
    var body: some View {
        List{
            Section {
                Button {
                    if peripheral.status == PeripheralStatus.disconnected.rawValue {
                        peripheral.connect()
                    } else {
                        peripheral.disconnect()
                    }
                } label: {
                    if peripheral.status == PeripheralStatus.connected.rawValue {
                        Text("Disconnect")
                    } else if peripheral.status == PeripheralStatus.disconnected.rawValue {
                        Text("Connect")
                    } else {
                        Text("Cancel")
                    }
                }
                .disabled(!peripheral.isConnectable)
                
            } header: {
                Text("Action")
            }
            
            Section {
                HStack{
                    Text(peripheral.status)
                        .frame(maxWidth: .infinity)
                    Divider()
                    Text("RSSI: \(peripheral.lastDetectedRSSI)").frame(maxWidth: .infinity)
                }
            } header: {
                Text("Status")
            }
            
            Section{
                ForEach(Array(peripheral.peripherasAdvertisementData.keys), id:\.self){key in
                    if let nextItem = peripheral.peripherasAdvertisementData[key] as? String{
                        Text("\(key) : \(nextItem)")
                    }else if let nextItem = peripheral.peripherasAdvertisementData[key] as? Int{
                        Text("\(key) : \(nextItem)")
                    }
                    else {
                        Text("\(key) : \(String(describing: peripheral.peripherasAdvertisementData[key]))")
                    }
                }
            } header: {
                Text("Advertisement Data")
            }
        }
    }
}

enum PeripheralStatus: String {
    case connected = "Connected"
    case disconnected = "Disconnected"
}
