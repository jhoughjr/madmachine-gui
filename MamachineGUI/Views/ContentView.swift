//
//  ContentView.swift
//  MamachineGUI
//
//  Created by Jimmy Hough Jr on 12/27/22.
//

import SwiftUI
import FilePicker

struct InitContext {
    let name:String
    let projectType:ProjectManager.Project.ProjectType
    let board:ProjectManager.Project.BoardType
    let verbose:Bool
}

struct BuildContext {
    let verbose:Bool
}





struct ContentView: View {
    var sectionPadding:CGFloat = 25
    
    @AppStorage("cwdp") var workingDirPath = ""
    @AppStorage("mmsdkpath") var mmsdkPath = ""
    
    @ObservedObject var runner = Runner()
    @ObservedObject var projMan = ProjectManager.shared
    @ObservedObject var watcher = ProjectWatcher()
    @ObservedObject var fileSelections = FileSelections()
    
    @State var showingAbout = false
    @State var selectedProject:ProjectManager.Project?
    @State var projectsCollapsed = true
    @State var serialCollapsed = true
    @State var outputCollapsed = true
    @State var commandsCollapsed = true
    
    var pathPicker: some View {
        VStack(alignment:.leading) {
            HStack {
                Text("Active Configuration")
                    .font(.title)
                    .padding([.bottom], 10)
                
             Spacer()
                Button {
                    $showingAbout.wrappedValue = true
                } label: {
                    Image(systemName: "questionmark.bubble")
                        .buttonStyle(PlainButtonStyle())
                }
                .buttonStyle(.borderless)
                .popover(isPresented: $showingAbout,
                         content: {AboutView()})

            }
            HStack {
                Text("SwiftIO Project Directory")
                    .font(.body)
                    .fontWeight(.bold)
                    .padding([.leading], sectionPadding)
                Button {
                    
                } label: {
                    Image(systemName: "arrow.up")
                }
                Button {
                    
                } label: {
                    Image(systemName: "arrow.down")
                    
                }
            }
            HStack {
                TextField("Woring Dir", text: $workingDirPath)
                    .padding([.leading], sectionPadding)
                FilePicker(types: [.folder],
                           allowMultiple: true,
                           folders: true,
                           title: "Choose ...") {
                    if let _ = selectedProject {
                        
                        selectedProject!.workingDir = $0.first?.absoluteString ?? ""
                    
                    }
                    self.workingDirPath = $0.first?.absoluteString ?? ""
                }
            }
            HStack {
                Text("MadMachine SDK Directory")
                    .font(.body )
                    .fontWeight(.bold)
                    .padding([.leading], sectionPadding)
                Button {
                    
                } label: {
                    Image(systemName: "arrow.up")
                    
                }
                Button {
                    
                } label: {
                    Image(systemName: "arrow.down")
                    
                }
            }
            HStack {
                TextField("Madmachine SDK Dir", text: $mmsdkPath)
                    .padding([.leading], sectionPadding)

                FilePicker(types: [.folder],
                           allowMultiple: true,
                           folders: true,
                           title: "Choose...") {
                    if let _ = selectedProject {
                        
                        selectedProject!.mmsdk = $0.first?.absoluteString ?? ""
                    
                    }
                    self.mmsdkPath = $0.first?.absoluteString ?? ""
                }
            }
        }
    }
    
    var body: some View {
        
        VStack {
            ProjectListView(selectedProject: $selectedProject)
            SerialPortView()
            HSplitView {
                    FSView(project: selectedProject,
                           projectWatcher: watcher,
                           fileSelections: fileSelections)
                if let p = selectedProject {
                    EditorView(fileSelections: fileSelections,
                               project: p)
                }
            }
        }
    }
}
