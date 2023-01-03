//
//  SerialPortView.swift
//  MamachineGUI
//
//  Created by Jimmy Hough Jr on 12/30/22.
//

import SwiftUI
import ORSSerial

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
                .buttonStyle(.borderless)
                .disabled(port.isOpen)
                
                Button {
                    serial.selectedPort?.close()
                } label: {
                    Text("close Port")
                }
                .buttonStyle(.borderless)
                .disabled(!port.isOpen)
                Button {
                    serial.lines.removeAll()
                    serial.portBuffer = ""
                } label: {
                    Text("Clear")
                }
                .buttonStyle(.borderless)

            }
        }
    }
    
    var body: some View {
        VStack(alignment:.leading) {
            HStack {
                Text("Serial Monitor")
                    .font(.title)
                Button {
//                    withAnimation {
                        serialCollapsed.toggle()
//                    }
                    
                } label: {
                    serialCollapsed ? Image(systemName: "arrow.down") : Image(systemName: "arrow.up")
                }
                .buttonStyle(.borderless)

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
        .padding()

    }
}
