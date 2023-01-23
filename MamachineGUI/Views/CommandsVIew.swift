//
//  CommandsVIew.swift
//  MamachineGUI
//
//  Created by Jimmy Hough Jr on 1/3/23.
//

import SwiftUI

struct CommandOutputView:View {
    @ObservedObject var runner:Runner
    @State var outputCollapsed = false
    @AppStorage("logTimestamps") var logTimestamps = false
    
    var title: some View {
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
                withAnimation {
                    outputCollapsed.toggle()
                }
            } label: {
                outputCollapsed ? Image(systemName: "arrow.down") : Image(systemName: "arrow.up")
            }
            .buttonStyle(.borderless)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            title
            if !outputCollapsed {
                Toggle("Timestamps", isOn: $logTimestamps)
                    .padding([.leading], 25)
                TextEditor(text:$runner.output)
                    .padding([.leading],25)
            }
            Divider()
        }
    }
}

struct CommandsView:View {
    @Binding var selectedProject:ProjectManager.Project?
    @State var commandsCollapsed = false
    
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
   
    var expanded:some View {
        VStack(alignment: .leading,
               spacing: 0) {
           
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
            CommandOutputView(runner: runner)
        }
    }
    
    @State var myFrame:CGRect = CGRect.zero
    
    var title: some View {
        HStack {
            Text("MMSDK Commands")
                .font(.title)
                .readFrame(in:.global,for:$myFrame)
                .gesture(DragGesture(minimumDistance: 0,
                                                 coordinateSpace: .global)
                    .onEnded({ gestureValue in
                        print("LOC: \(gestureValue.location)")
                        print("FRAME: \(myFrame)")
                        print("\(myFrame.contains(gestureValue.location) ? "IN" : "OUT")")
                    })
                )
//            Button {
//                withAnimation {
//                    commandsCollapsed.toggle()
//                }
//            } label: {
//                commandsCollapsed ? Image(systemName: "arrow.down") : Image(systemName: "arrow.up")
//            }
//            .buttonStyle(.borderless)
            
        }
    }
    
    var body: some View {
        VStack(alignment:.leading,
               spacing:0) {
            title
            expanded
            Divider()
        }
        .padding()
    }
}

