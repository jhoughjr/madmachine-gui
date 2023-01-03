//
//  EditProjectView.swift
//  MamachineGUI
//
//  Created by Jimmy Hough Jr on 1/3/23.
//

import SwiftUI
import FilePicker

struct EditProjectView:View {
    
    @ObservedObject var projMan = ProjectManager.shared
    @State var project:ProjectManager.Project

    var body: some View {
        VStack {
            Text("Name")
            TextField("name", text: $project.name)
            Text("MMSDK")
            HStack {
                TextField("MMSDK", text: $project.mmsdk)
                FilePicker(types: [.folder],
                           allowMultiple: true,
                           folders: true,
                           title: "Choose...") {
                        
                        project.mmsdk = $0.first?.absoluteString ?? ""
                        projMan.save(project)
                }
            }
            Text("Working Directory")
            HStack {
                TextField("Working Directory", text: $project.workingDir)
                FilePicker(types: [.folder],
                           allowMultiple: true,
                           folders: true,
                           title: "Choose ...") {
                  
                    self.project.workingDir = $0.first?.absoluteString ?? ""
                    projMan.save(project)
                }
            }
            
            
            Button {
                projMan.save(project)
            } label: {
                Text("Save")
            }
            .buttonStyle(.borderless)

        }
        .onChange(of: project) { newValue in
            print("\(newValue)")
        }
    }
}

