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
    @State var project:ProjectManager.Project? = nil
    
    @ObservedObject var projectWatcher = ProjectWatcher()
    @ObservedObject var fileSelections:FileSelections
    @ObservedObject var runner = Runner()
    @State var filesCollapsed = false
    
    var collapseControl: some View {
        HStack {
            Text("Files")
                .font(.title)
            Button {
                withAnimation {
                    filesCollapsed.toggle()

                }
                
            } label: {
                filesCollapsed ? Image(systemName: "arrow.down") : Image(systemName: "arrow.up")
            }
            .buttonStyle(.borderless)
            .help(filesCollapsed ? "Expand Files" : "Collapse Files")

            if let f = fileSelections.selectedEditorFile {
                Text("\(f)")
                openSelected
            }
        }
    }
    
    func isDir(_ filePath:String) -> Bool {
        var res:ObjCBool = false
        
        FileManager.default.fileExists(atPath: filePath,
                                       isDirectory: &res)
        return res.boolValue
    }
    
    var openSelected:some View {
        Button {
            runner.run(.open,
                       ctx:fileSelections.selectedEditorFile)
        } label: {
            Image(systemName: "square.and.arrow.up")
                .fontWeight(.ultraLight)
        }
        .buttonStyle(.borderless)
        .help("Open in extenal app.")
    }
    
    var body:some View {
        
        VStack(alignment:.leading) {
            if !filesCollapsed {
                Text("Files")
                    .font(.title)
                HStack {
                    Text("\(URL(filePath: fileSelections.workingDIr).path())")
                    
                    Button {
                        fileSelections.selection = URL(filePath: fileSelections.workingDIr).deletingLastPathComponent().path
                    } label: {
                        Text("../")
                            .help("Move to parent directory.")
                    }
                    .buttonStyle(.borderless)
                }
                Divider()
                List {
                    ForEach($fileSelections.currentDirContents.wrappedValue.isEmpty ? projectWatcher.workingFiles : $fileSelections.currentDirContents.wrappedValue,
                            id:\.self) { filepath in
                        HStack {
                            if isDir(filepath) {
                                Image(systemName: "folder")
                            }else {
                                Image(systemName: "doc")
                            }
                            Text("\(URL(filePath: filepath).lastPathComponent)")
                                .foregroundColor(fileSelections.selectedEditorFile == filepath ? .accentColor : .primary)
                                .onTapGesture {
                                    $fileSelections.selection.wrappedValue = filepath
                                }
                            
                           openSelected

                        }
                    }
                }
                .padding()
                
            }

            Divider()
        }
        .onChange(of: project,
                  perform: { v in
            print("project changed")
            if let proj = v {
                projectWatcher.look(at:proj)
                fileSelections.project = proj
                fileSelections.selectedEditorFile = "\(proj.workingDir.replacingOccurrences(of: "file://", with: ""))Sources/\(proj.name)/\(proj.name).swift"
            }
        })
        .padding([.leading],20)
       
    }
}
