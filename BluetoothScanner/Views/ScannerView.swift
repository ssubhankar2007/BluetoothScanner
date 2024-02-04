//
//  ScannerView.swift
//  BluetoothScanner
//
//  Created by Subhankar Ghosh on 05/02/24.
//

import SwiftUI

struct ScannerView: View {
    @ObservedObject var viewModel = BluetoothViewModel()
    @State var refresh: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack() {
                Text("Bluetooth Devices (\(viewModel.peripherals.count))")
                    .font(.title)
                    .frame(alignment: .leading)
                    .padding()
                
                
                List {
                    ForEach(Array(viewModel.peripherals.values).sorted(by: {$0.lastDetectedRSSI > $1.lastDetectedRSSI}), id: \.self) { value in
                        NavigationLink {
                            PeripheralView(peripheral: value)
                                .navigationTitle(value.name)
                        } label: {
                            Text(value.name)
                        }
                        
                    }
                }
                .refreshable {
                    refresh = true
                    
                    if (viewModel.isScanning) {
                        viewModel.stopScan()
                    }
                    viewModel.startScan()
                    
                    refresh = false
                }
                
                Button(action: {
                    viewModel.isScanning ? viewModel.stopScan() : viewModel.startScan()
                }, label: {
                    viewModel.isScanning ? Text("Stop Scanning") : Text("Start Scan")
                })
                .disabled(refresh)
                .padding()
            }
        }
        .background(.clear)
    }
}

#Preview {
    ScannerView()
}
