//
//  SerialPortView.swift
//  MamachineGUI
//
//  Created by Jimmy Hough Jr on 12/30/22.
//

import Foundation
import SwiftUI
import ORSSerial
import CodeEditorView

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
    
    func ports() -> [ORSSerialPort] {
        let ports = ORSSerialPortManager.shared().availablePorts
        print("\(ports)")
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
        print("Got \(string) from the serial port!")
        portBuffer += string ?? ""
    }
    func serialPortWasRemovedFromSystem(_ serialPort: ORSSerialPort) {
        print("\(serialPort.path) was removed")
    }
    
    func serialPortWasOpened(_ serialPort: ORSSerialPort) {
        self.openPort = serialPort
    }
    
    func serialPortWasClosed(_ serialPort: ORSSerialPort) {
        self.openPort = nil
    }

}

struct SerialPortView:View {
    @ObservedObject var serial = SerialMan.shared

    var buttons: some View {
        HStack {
            
            if let port = serial.selectedPort {
                Button {
                    port.baudRate = 115200
                    port.open()
                } label: {
                    Text("Open Port")
                }
                .disabled(port.isOpen)
                
                Button {
                    serial.selectedPort?.close()
                } label: {
                    Text("close Port")
                }
                .disabled(!port.isOpen)
            }
        }
    }
    
    var body: some View {
        VStack(alignment:.leading) {
            Text("Serial Monitor")
                .font(.title)
            Group {
                ForEach(serial.ports(), id:\.self) { t in
                    HStack {
                       
                        Text(t.path)
                            .foregroundColor(t == serial.selectedPort ? .accentColor : .primary)
                    }
                    .onTapGesture {
                        serial.selectedPort = t
                    }
                    
                    
                }
                buttons
                TextEditor(text: $serial.portBuffer)
                Divider()
                
            }
            .onAppear(perform: {
                serial.selectStoredSelectedPort()
            })
            .padding([.leading], 25)
        }

    }
}

struct FSView:View {
    let manager = FileManager.default
    
    var project:ProjectManager.Project? = nil
    
    var body:some View {
        
        VStack(alignment:.leading) {
            if let p = project?.workingDir {
                
            }else {
                Text("Select a project")
            }
          
        }
    }
}

struct EditorView:View {
    @State private var text:     String                = "My awesome code..."
    @State private var position: CodeEditor.Position  = CodeEditor.Position()
    @State private var messages: Set<Located<Message>> = Set()

    @Environment(\.colorScheme) private var colorScheme: ColorScheme

    var body: some View {
        VStack {
            CodeEditor(text: $text,
                       position: $position,
                       messages: $messages,
                       language: .swift)
              .environment(\.codeEditorTheme,
                           colorScheme == .dark ? Theme.defaultDark : Theme.defaultLight)
        }
     
    }
}
