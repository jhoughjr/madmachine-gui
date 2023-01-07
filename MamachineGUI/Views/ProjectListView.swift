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
    
    @State var projectsCollapsed = true
    
    var sectionPadding:CGFloat = 25
    
    var titleView: some View {
        HStack {
            Text("Projects")
                .font(.title)
            
            Button {
                withAnimation {
                    projectsCollapsed.toggle()
                }
            } label: {
                projectsCollapsed ? Image(systemName: "arrow.down") : Image(systemName: "arrow.up")
            }
            .buttonStyle(.borderless)
            if let p = selectedProject {
                Text("\(p.name)")
            }else {
                Text("Select a project.")
            }

        }
    }
    
    var body: some View {
        VStack(alignment:.leading) {
            titleView
            if !projectsCollapsed {
                HStack {
                    Button {
                        projectMan.save()
                    } label: {
                        Text("Save")
                    }
                    .buttonStyle(.borderless)
                    Button {
                        projectMan.load()
                    } label: {
                        Text("Load")
                    }
                    .buttonStyle(.borderless)
                    Button {
                        showingNew = true
                    } label: {
                        Text("New ...")
                    }
                    .buttonStyle(.borderless)
                    .popover(isPresented: $showingNew,
                             content:{ NewProjectView() })
                    
                    
                    
                }
                .padding([.leading], sectionPadding)
                

                    HStack {
                        ForEach(projectMan.projects,
                                id:\.name) { project in
                            if project == $selectedProject.wrappedValue {
                                Button {
                                    showingEdit.toggle()
                                } label: {
                                    Text("Edit")
                                }
                                .popover(isPresented: $showingEdit,
                                         content: {EditProjectView(project:project )})
                                
                            }
                            Text(project.name)
                                .onTapGesture {
                                    if project == $selectedProject.wrappedValue {
                                        $selectedProject.wrappedValue = nil
                                    }else {
                                        $selectedProject.wrappedValue = project
                                    }
                                }
                                .foregroundColor(selectedProject == project ? .yellow : .white)
                        }
                        //                    }
                    }

                .padding([.leading], sectionPadding)
            }
            Divider()
        }
        .padding()
        .onAppear {
            projectMan.load()
        }
        
    }
}
