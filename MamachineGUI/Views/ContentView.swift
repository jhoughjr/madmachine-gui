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
    
    var body: some View {
        HSplitView {
            if let p = selectedProject {
                FSView(project: p,
                       projectWatcher: watcher,
                       fileSelections: fileSelections)
                if fileSelections.selection.isEmpty == false {
                    EditorView(fileSelections: fileSelections,
                               project: $selectedProject)
                }
            }else {
                ProjectListView(selectedProject: $selectedProject)
            }
            
        }
        .onChange(of: selectedProject) { newValue in
            if let p = newValue {
                
                watcher.look(at: p)
                fileSelections.workingDIr = p.workingDir.replacingOccurrences(of: "file://", with: "")
            }
        }
    }
}
