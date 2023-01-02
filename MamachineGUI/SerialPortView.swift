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
    @State var serialCollapsed = true
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
            HStack {
                Text("Serial Monitor")
                    .font(.title)
                Button {
                    serialCollapsed.toggle()
                } label: {
                    serialCollapsed ? Image(systemName: "arrow.up") : Image(systemName: "arrow.down")
                }

            }
            if !serialCollapsed {
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
            }
            Divider()
        }

    }
}

class ProjectWatcher:ObservableObject {
    @Published var workingFiles:[String] = [String]() {
        didSet {
            print("\(workingFiles)")
        }
    }
    
    func look(at:ProjectManager.Project) {
        let foo = at.workingDir.replacing("file://", with: "")
        print("looking at \(foo)")

        if let fs = try? FileManager.default.contentsOfDirectory(atPath: foo) {
            workingFiles = fs.map({"\(foo)\($0)"})
        }else {
            print("couldn't look")
        }
    }
    
}

class FileSelections:ObservableObject {
    @Published var project:ProjectManager.Project? = nil {
        didSet {
            workingDIr = project?.workingDir ?? ""
        }
    }
    @Published var previousDirectory = ""
    
    @Published var selection = "" {
        didSet {
            print("didSet FileSelections.selection \(selection)")
            var isDir:ObjCBool = false
            
            let path = selection
            print("Checking path \(path)")
            _ = FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
            if isDir.boolValue {
                previousDirectory = workingDIr
                workingDIr = path
                if let fs = try? FileManager.default.contentsOfDirectory(atPath: path) {
                    let foo = workingDIr.replacing("file://", with: "")
                    
                    currentDirContents = fs.map({"\(foo)/\($0)"})
                }else {
                    print("couldn't look")
                }
            }else {
                print("selected file, setting editorFIle")
                selectedEditorFile = selection
            }
        }
    }
    
    @Published var workingDIr = "" {
        didSet {
            print("workingDIr = \(workingDIr)")
        }
    }
    
    @Published var selectedEditorFile = "" {
        didSet {
            print("selectedEditorFile = \(selectedEditorFile)")
        }
    }
    
    @Published var currentDirContents = [String]() {
        didSet {
            print("currnt \(currentDirContents)")
        }
    }
}

struct FSView:View {
    
    let manager = FileManager.default
    var project:ProjectManager.Project? = nil
    
    @ObservedObject var projectWatcher = ProjectWatcher()
    @ObservedObject var fileSelections:FileSelections
    @State var filesCollapsed = true
    
    var collapseControl: some View {
        HStack {
            Text("Files")
                .font(.title)
            Button {
                filesCollapsed.toggle()
            } label: {
                filesCollapsed ? Image(systemName: "arrow.up") : Image(systemName: "arrow.down")
            }

        }
    }
    
    var body:some View {
        
        VStack(alignment:.leading) {
           collapseControl
            Text("\(URL(filePath: fileSelections.workingDIr).path())")

            if !filesCollapsed {
                    Button {
                        fileSelections.selection = URL(filePath: fileSelections.workingDIr).deletingLastPathComponent().path
                    } label: {
                        Text("..")
                    }

                    Divider()
                List {
                    ForEach($fileSelections.currentDirContents.wrappedValue.isEmpty ? projectWatcher.workingFiles : $fileSelections.currentDirContents.wrappedValue,
                            id:\.self) { filepath in
                        
                        Text("\(URL(filePath: filepath).lastPathComponent)")
                            .foregroundColor(fileSelections.selectedEditorFile == filepath ? .accentColor : .primary)
                            .onTapGesture {
                                $fileSelections.selection.wrappedValue = filepath
                            }
                    }
                }
            }

            Divider()
        }
        .padding()
        .onChange(of: project,
                  perform: { v in
            print("project changed")
            if let proj = v {
                    projectWatcher.look(at:proj)
                fileSelections.project = proj
            }
        })
       
    }
}

// Represents a simple file or a folder
struct File: Identifiable { // identifiable ✓
  let id = UUID()
  let name: String
  var children: [File]? // optional array of type File ✓

  var icon: String { // makes things prettier
    if children == nil {
       return "doc"
    } else if children?.isEmpty == true {
       return "folder"
    } else {
       return "folder.fill"
    }
  }
}

struct EditorView:View {
    @State private var text:     String                = "My awesome code..."
    @State private var position: CodeEditor.Position  = CodeEditor.Position()
    @State private var messages: Set<Located<Message>> = Set()

    @State var checksum = ""
    
    @ObservedObject var fileSelections:FileSelections
    @State var project:ProjectManager.Project
    
    @Environment(\.colorScheme) private var colorScheme: ColorScheme

    var editorCommands: some View {
        HStack {
            Button {
                if  !fileSelections.selectedEditorFile.isEmpty {
                    
                    let url = URL(filePath: fileSelections.selectedEditorFile)
                    do {
                        try $text.wrappedValue.data(using: .utf8)?.write(to: url)
                        DispatchQueue.main.async {
                            $checksum.wrappedValue = $text.wrappedValue.md5
                        }
                        
                    }
                    catch {
                        print(error)
                    }
                }
            } label: {
                Text("Save")
            }
            .disabled(checksum == text.md5)
        }
    }
    var body: some View {
        VStack(alignment:.leading) {
            Text("Code Editor")
                .font(.title)
            editorCommands
            CodeEditor(text: $text,
                       position: $position,
                       messages: $messages,
                       language: .swift)
              .environment(\.codeEditorTheme,
                           colorScheme == .dark ? Theme.defaultDark : Theme.defaultLight)
        }
        .onChange(of: fileSelections.selectedEditorFile,
                  perform: { newValue in

            let path = newValue
            
            if let d = FileManager.default.contents(atPath: path) {
                
                let loadedText = String(data: d,
                                        encoding: .utf8) ?? "Couldnt load utf8"
                
                $text.wrappedValue = loadedText
                checksum = loadedText.md5
            }else {
                print("no data at  \(path)")
            }
        })
     
    }
}
import CommonCrypto

extension String {
    var md5: String {
        let data = Data(self.utf8)
        let hash = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> [UInt8] in
            var hash = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            CC_MD5(bytes.baseAddress, CC_LONG(data.count), &hash)
            return hash
        }
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}
