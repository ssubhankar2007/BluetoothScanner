//
//  BluetoothViewModel.swift
//  BluetoothScanner
//
//  Created by Subhankar Ghosh on 04/02/24.
//

import Foundation
import CoreBluetooth
import Combine

class BluetoothViewModel: NSObject, ObservableObject {
    private var centralManager: CBCentralManager?
    @Published var isScanning = false
    @Published var error: BluetoothError?
    @Published var peripherals: [UUID: PeripheralManager] = [:]
    private var connectedPeripheral: PeripheralManager?
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: .main)
    }
}


extension BluetoothViewModel: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            startScan()
        case .poweredOff:
            error = BluetoothError.bluetoothPoweredOff
        case .unsupported:
            error = BluetoothError.bluetoothUnsupported
        case .unauthorized:
            error = BluetoothError.bluetoothUnauthorized
        case .unknown:
            error = BluetoothError.unknown
        case .resetting:
            print("Try again")
        @unknown default:
            print("Bluetooth state \(central.state)")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard !peripherals.keys.contains(peripheral.identifier) else {return}
        let newPeripheral = PeripheralManager(peripheral: peripheral, viewModel: self, advertisementData: advertisementData)
        peripherals[peripheral.identifier] = newPeripheral
        if let localName = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            newPeripheral.name = localName
        } else {
            newPeripheral.name = peripheral.name ?? "\(peripheral.identifier)"
        }
        newPeripheral.peripherasAdvertisementData = advertisementData
        newPeripheral.lastDetectedRSSI = RSSI.intValue
    }
    
    func startScan() {
        if (peripherals.count != 0) {
            peripherals.removeAll()
        }
        centralManager?.scanForPeripherals(withServices: nil)
        isScanning = true
    }
    
    func stopScan() {
        centralManager?.stopScan()
        isScanning = false
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if peripherals.keys.contains(peripheral.identifier) {
            connectedPeripheral = peripherals[peripheral.identifier]
            connectedPeripheral?.peripheral?.delegate = connectedPeripheral
            connectedPeripheral?.peripheral?.discoverServices(nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        guard error == nil else { return }
        
        if peripherals.keys.contains(peripheral.identifier) {
            connectedPeripheral = peripherals[peripheral.identifier]
        }
    }
    
    //MARK: - Peripheral
    func connect(peripheral: CBPeripheral) {
        centralManager?.connect(peripheral)
    }
    
    func disconnect(peripheral: CBPeripheral){
        centralManager?.cancelPeripheralConnection(peripheral)
    }
}
