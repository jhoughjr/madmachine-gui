//
//  CommandsVIew.swift
//  MamachineGUI
//
//  Created by Jimmy Hough Jr on 1/3/23.
//

import SwiftUI
struct CommandsView:View {
    @AppStorage("logTimestamps") var logTimestamps = false
    @State var outputCollapsed = false
    @State var selectedProject:ProjectManager.Project?
    @State var commandsCollapsed = true
    
    @ObservedObject var runner = Runner()
    // shold make validation on concrete types instead
    func hasContext(for command:Runner.MMSDKCommands) -> Bool {
        switch command {
            
        case .initializeProject:
            return true
        case .build:
            return true
        case .addHeader:
            return true
        case .download:
            return true
        case .clean:
            return true
        case .get:
            return true
        case .ci_build:
            return true
        case .host_test:
            return true
        }
    }
    
    // command / subcommand / value
    @State var contexts = [Runner.MMSDKCommands:[String:String]]()
    
    var outputView:some View {
        VStack(alignment: .leading) {
           
            HStack {
                Text("Output")
                    .font(.title)
                Button {
                    runner.clearOutput()
                } label: {
                    Text("Clear")
                }
                .buttonStyle(.borderless)
                Button {
//                    withAnimation {
                        outputCollapsed.toggle()
//                    }
                } label: {
                    outputCollapsed ? Image(systemName: "arrow.down") : Image(systemName: "arrow.up")
                }
                .buttonStyle(.borderless)

            }
            if !outputCollapsed {
                TextEditor(text:$runner.output)
                    .padding([.leading],25)
            }
            Divider()
        }
        
    }
    
    var body: some View {
        VStack(alignment:.leading) {
            HStack {
                Text("MMSDK Commands")
                    .font(.title)
                Button {
//                    withAnimation {
                        commandsCollapsed.toggle()
//                    }
                } label: {
                    commandsCollapsed ? Image(systemName: "arrow.down") : Image(systemName: "arrow.up")
                }
                .buttonStyle(.borderless)

            }
            
            if !commandsCollapsed {
                Toggle("Timestamps", isOn: $logTimestamps)
                    .padding([.leading], 25)
                HStack {
                    Group {
                        
                        ForEach(Runner.MMSDKCommands.allCases, id:\.self) { command in
                            Button {
                                runner.run(command, for: selectedProject)
                            } label: {
                                Text(command.label)
                            }
                            .buttonStyle(.borderless)
                            .disabled(!hasContext(for: command))
                            //
                        }
                    }
                }
                .padding([.leading], 25)
                outputView
            }
        }
    }
}
