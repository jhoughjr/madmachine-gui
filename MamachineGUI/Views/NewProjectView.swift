//
//  NewProjectView.swift
//  MamachineGUI
//
//  Created by Jimmy Hough Jr on 1/3/23.
//

import SwiftUI
import FilePicker

struct NewProjectView: View {
    @AppStorage("mmsdkpath") var mmsdkPath = ""
    @State var newProject = ProjectManager.Project(name: "New Project",
                                                   mmsdk: "",
                                                   workingDir: "",
                                                   type:.executable, boardName: .SwiftIOBoard)
    var projMan = ProjectManager.shared
    
    var body: some View {
        VStack {
            Text("Name")
            TextField("name", text: $newProject.name)
            Text("MMSDK")
            HStack {
                TextField("MMSDK", text: $newProject.mmsdk)
                FilePicker(types: [.folder],
                           allowMultiple: true,
                           folders: true,
                           title: "Choose...") {
                        
                        newProject.mmsdk = $0.first?.absoluteString ?? ""
                        projMan.save(newProject)
                }
            }
            Text("Working Directory")
            HStack {
                TextField("Working Directory", text: $newProject.workingDir)
                FilePicker(types: [.folder],
                           allowMultiple: true,
                           folders: true,
                           title: "Choose ...") {
                  
                    self.newProject.workingDir = $0.first?.absoluteString ?? ""
                    projMan.save(newProject)
                }
            }
            
            
            Button {
                projMan.save(newProject)
            } label: {
                Text("Create")
            }
            .buttonStyle(.borderless)

        }
    }
}
