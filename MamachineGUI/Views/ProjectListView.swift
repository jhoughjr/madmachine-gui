//
//  ProjectListView.swift
//  MamachineGUI
//
//  Created by Jimmy Hough Jr on 1/3/23.
//

import SwiftUI
struct ProjectListView: View {

    @ObservedObject var projectMan = ProjectManager.shared
    @Binding var selectedProject:ProjectManager.Project?
    
    @State var showingNew = false
    @State var showingEdit = false
    
    @State var projectsCollapsed = false
    
    var sectionPadding:CGFloat = 25
    
    var titleView: some View {
        HStack {
            Text("Projects")
                .font(.title)
            
//            Button {
//                withAnimation {
//                    projectsCollapsed.toggle()
//                }
//            } label: {
//                projectsCollapsed ? Image(systemName: "arrow.down") : Image(systemName: "arrow.up")
//            }
//            .buttonStyle(.borderless)
            
            if let p = selectedProject {
                Text("\(p.name)")
            }
        }
    }
    
    var newButton: some View {
        Button {
            showingNew = true
        } label: {
            Text("New ...")
        }
        .buttonStyle(.borderless)
        .popover(isPresented: $showingNew,
                 content:{ NewProjectView() })
    }
    
    var list: some View {
        List {
            ForEach(projectMan.projects,
                    id:\.name) { project in
                
                HStack {
                    Text(project.name)
                        .onTapGesture {
                            if project == $selectedProject.wrappedValue {
                                $selectedProject.wrappedValue = nil
                            }else {
                                $selectedProject.wrappedValue = project
                            }
                        }
                        .foregroundColor(selectedProject == project ? .yellow : .white)
                    
                    if project == $selectedProject.wrappedValue {
                        Button {
                            showingEdit.toggle()
                        } label: {
                            Text("Edit")
                        }
                        .popover(isPresented: $showingEdit,
                                 content: {EditProjectView(project:project )})
                        
                    }
                }
                
            }
        }
        .frame(maxHeight: 100)
        .onTapGesture {
            $selectedProject.wrappedValue = nil
        }
    }
    
    var body: some View {
        VStack(alignment:.leading, spacing: 0) {
            titleView
            if !projectsCollapsed {
                newButton
                list
            }
            Divider()
        }
       
        .onAppear {
            projectMan.load()
        }        
    }
}
