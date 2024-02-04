//
//  Peripheral.swift
//  BluetoothScanner
//
//  Created by Subhankar Ghosh on 05/02/24.
//

import Foundation
import CoreBluetooth
import Combine

class PeripheralManager: NSObject, ObservableObject {
    @Published var isConnectable = false
    @Published var status = "Pending"
    @Published var services : [CBService] = []
    
    var peripheral: CBPeripheral?
    var name = "Unknown"
    var lastDetectedRSSI = 0
    var peripherasAdvertisementData: Dictionary<String, Any> {
        didSet{
            self.isConnectable = checkIfConnectable()
        }
    }
    
    let viewModel : BluetoothViewModel
    var scannedData: [PeripheralModel] = []
    var cancellable: Cancellable?
    
    init(peripheral: CBPeripheral, viewModel: BluetoothViewModel, advertisementData: Dictionary<String, Any> = [:]) {
        self.peripheral = peripheral
        self.viewModel = viewModel
        self.peripherasAdvertisementData = advertisementData
        super.init()
        cancellable = self.peripheral?.publisher(for: \.state)
            .sink(receiveValue: {[weak self] state in
                self?.status = state.description
            })
    }
    
    func connect() {
        if self.peripheral != nil {
            self.viewModel.connect(peripheral: self.peripheral!)
        }
    }
    
    func disconnect() {
        if self.peripheral != nil {
            self.viewModel.disconnect(peripheral: self.peripheral!)
        }
    }
    
    func checkIfConnectable() -> Bool{
        if let value = self.peripherasAdvertisementData["kCBAdvDataIsConnectable"], let val = value as? Int {
            return val == 1
        }
        return false
    }
}

extension PeripheralManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else {return}
        
        if let services = peripheral.services{
            self.services = services
            for service in self.services {
                let results = scannedData.filter {$0.id == service.uuid}
                if results.isEmpty{
                    let newData = PeripheralModel(id: service.uuid)
                    scannedData.append(newData)
                }
            }
        }
        
    }
}

extension CBPeripheralState {
    var description: String {
        switch self {
        case .connected:
            return "Connected"
        case .connecting:
            return "Connecting"
        case .disconnecting:
            return "Disconnecting"
        case .disconnected:
            return "Disconnected"
        @unknown default:
            return "Unknown"
        }
    }
}
