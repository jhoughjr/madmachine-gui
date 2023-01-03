//
//  FSView.swift
//  MamachineGUI
//
//  Created by Jimmy Hough Jr on 1/3/23.
//

import SwiftUI

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

struct FSView:View {
    
    let manager = FileManager.default
    var project:ProjectManager.Project? = nil
    
    @ObservedObject var projectWatcher = ProjectWatcher()
    @ObservedObject var fileSelections:FileSelections
    @ObservedObject var runner = Runner()
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
                        HStack {
                            Text("\(URL(filePath: filepath).lastPathComponent)")
                                .foregroundColor(fileSelections.selectedEditorFile == filepath ? .accentColor : .primary)
                                .onTapGesture {
                                    $fileSelections.selection.wrappedValue = filepath
                                }
                            Button {
                                runner.run(.openInXcode,
                                           ctx:fileSelections.selectedEditorFile)
                            } label: {
                                Text("Xcode")
                            }

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
