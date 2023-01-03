//
//  SerialManger.swift
//  MamachineGUI
//
//  Created by Jimmy Hough Jr on 1/3/23.
//

import SwiftUI
import ORSSerial

class SerialMan:NSObject, ObservableObject, ORSSerialPortDelegate {
   
    @AppStorage("selectedPortPath")
    private var selectedPortPath = ""
    
    static let shared = SerialMan()
    
    @Published var selectedPort:ORSSerialPort? = nil {
        didSet {
            if let port = selectedPort {
                selectedPortPath = port.path
            }else {
                selectedPortPath = ""
            }
        }
    }
    
    @Published var openPort:ORSSerialPort? = nil
    @Published var portBuffer = ""
    @Published var lines = [""]
    
    func ports() -> [ORSSerialPort] {
        let ports = ORSSerialPortManager.shared().availablePorts
        return ports
    }
    
    func selectStoredSelectedPort() {
        if let foundPort = ports().first(where: { p in
            p.path == selectedPortPath
        }) {
            selectedPort = foundPort
            selectedPort?.delegate = self
        }else {
            print("\(selectedPortPath) not found in ports()")
        }
    }
    
    // ORSSerialPortDelegate
    func serialPort(_ serialPort: ORSSerialPort, didReceive data: Data) {
        let string = String(data: data, encoding: .utf8)
        lines.append(string ?? "")
        portBuffer = lines.reversed().joined()
    }
    
    func serialPortWasRemovedFromSystem(_ serialPort: ORSSerialPort) {
        print("\(serialPort.path) was removed")
    }
    
    func serialPortWasOpened(_ serialPort: ORSSerialPort) {
        print("\(serialPort.path) was opened.")
        self.openPort = serialPort
    }
    
    func serialPortWasClosed(_ serialPort: ORSSerialPort) {
        print("\(serialPort.path) was closed.")
        self.openPort = nil
    }

}
