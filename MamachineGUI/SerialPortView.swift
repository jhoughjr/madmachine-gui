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
            if let port = serial.selectedPort {
                HStack {
                    Text("Port")
                        .font(.title2)
                    Text("\(port.path)")
                        .bold()
                        .onLongPressGesture {
                            serial.selectedPort = nil
                        }
                    buttons
                }
                .padding()
            }
            else {
                Text("Select serial port.")
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
                }
                .padding()
                .onAppear(perform: {
                    serial.selectStoredSelectedPort()
                })
                .padding([.leading], 25)
            }
            TextEditor(text: $serial.portBuffer)
            Divider()
        }

    }
}

class ProjectWatcher:ObservableObject {
    @Published var workingFiles:[String] = [String]()
    
    func look(at:ProjectManager.Project) {
        let foo = at.workingDir.replacing("file://", with: "")
        print("looking at \(foo)")

        if let fs = try? FileManager.default.contentsOfDirectory(atPath: foo) {
            print("got fs info")
            workingFiles = fs
        }else {
            print("couldn't look")
        }
    }
}

class FileSelections:ObservableObject {
    @Published var selectedEditorFile = ""
    
}

struct FSView:View {
    
    let manager = FileManager.default
    var project:ProjectManager.Project? = nil
    
    @ObservedObject var projectWatcher = ProjectWatcher()
    @ObservedObject var fileSelections:FileSelections
    
    var body:some View {
        
        VStack(alignment:.leading) {
            Text("Files")
                .font(.title)
            ForEach($projectWatcher.workingFiles.wrappedValue,
                        id:\.self) { filepath in
                    Text("\(filepath)")
                    .foregroundColor(fileSelections.selectedEditorFile == filepath ? .accentColor : .primary)
                    .onTapGesture {
                        
                        $fileSelections.selectedEditorFile.wrappedValue = filepath
                        print("\(fileSelections.selectedEditorFile)")
                    }
            }
            Spacer()
          
        }
        .padding()
        .onChange(of: project,
                  perform: { v in
            print("project changed")
            if let proj = v {
                    projectWatcher.look(at:proj)
            }
        })
        .onChange(of: projectWatcher.workingFiles) { newValue in
            print("fpp")
        }
    }
}

struct EditorView:View {
    @State private var text:     String                = "My awesome code..."
    @State private var position: CodeEditor.Position  = CodeEditor.Position()
    @State private var messages: Set<Located<Message>> = Set()

    @ObservedObject var fileSelections:FileSelections
    @State var project:ProjectManager.Project
    
    @Environment(\.colorScheme) private var colorScheme: ColorScheme

    var body: some View {
        VStack(alignment:.leading) {
            Text("Code Editor")
                .font(.title)
            CodeEditor(text: $text,
                       position: $position,
                       messages: $messages,
                       language: .swift)
              .environment(\.codeEditorTheme,
                           colorScheme == .dark ? Theme.defaultDark : Theme.defaultLight)
        }
        .onChange(of: fileSelections.selectedEditorFile,
                  perform: { newValue in
            print("new \(newValue)")

            let path = project.workingDir.appending(newValue)
                .replacingOccurrences(of: "file://",
                                      with: "")
            
            if let d = FileManager.default.contents(atPath: path) {
                
                $text.wrappedValue = String(data: d,
                                            encoding: .utf8) ?? "Couldnt load utf8"
            }else {
                print("no data at  \(path)")
            }
        })
        .padding()
     
    }
}
