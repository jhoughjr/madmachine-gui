//
//  ContentView.swift
//  MamachineGUI
//
//  Created by Jimmy Hough Jr on 12/27/22.
//

import SwiftUI
import FilePicker

struct AboutView:View {
    
    var body: some View {
        VStack {
            Text("MadMachine GUI")
                .font(.largeTitle)
            Text("2022 Jimmy Hough Jr et al.")
            Text("Made with Swift and love.")
            Divider()
            Text("""
            Firstly, choose the location of the mm-sdk to use.
            Secondly, choose the location of the project for your SwiftIO board.
            Thirdly, choose timestamps or not and press the button for the command to run.
            Fourthly, observe command output in the output area, optionally pressing clear to clear the output.
            """)
            .padding()
        }
    }
}

class OutputBuffer:ObservableObject {
    @Published var stdOut = ""
}

struct InitContext {
    let name:String
    let projectType:ProjectManager.Project.ProjectType
    let board:ProjectManager.Project.BoardType
    let verbose:Bool
}

struct BuildContext {
    let verbose:Bool
}

struct InitContextView: View {
    @Binding var context:InitContext
    
    var body: some View {
        VStack {
        
        }
    }
}

struct BuildContextView:View {
    @Binding var context:BuildContext
    var body: some View {
        VStack {
            
        }
    }
}

class ProjectManager:ObservableObject {
    static let shared = ProjectManager()
    
    struct Project:Codable, Equatable, Hashable {
        
        enum ProjectType:String, CaseIterable, Codable{
            case executable = "executable"
            case library = "library"
        }
        
        enum BoardType:String, CaseIterable, Codable {
            case SwiftIOBoard = "SwiftIOBoard"
            case SwiftIOFeather = "SwiftIOFeather"
        }
        
        let id :UUID
        var name:String
        var mmsdk:String
        var workingDir:String
        var type:ProjectType
        var boardName:BoardType
        
        init(id:UUID = UUID(),
             name:String,
             mmsdk:String,
             workingDir:String,
             type:ProjectType,
             boardName:BoardType
             ) {
            self.id = id
            self.name = name
            self.mmsdk = mmsdk
            self.workingDir = workingDir
            self.boardName = boardName
            self.type = type
        }
    }
    
    @AppStorage("projectList") var projectsList = Data()
    
    @Published var projects = [Project]()
    
    func load() {
        if let list = try? JSONDecoder().decode([Project].self,
                                             from: projectsList) {
            projects = list
            print("loaded.")
        }else {
            print("nothing to load.")
        }
    }
    func save(_ project:ProjectManager.Project) {
        if let existing = projects.firstIndex(where: { e in
            e.id == project.id
        }) {
            projects.remove(at: existing)
        }
            projects.append(project)
            save()
        
    }
    
    func save() {
        do {
            projectsList = try JSONEncoder().encode(projects)
        }
        catch {
            print(error)
        }
    }
    
    func remove(project:Project) {
        if let index = projects.firstIndex(of: project) {
            projects.remove(at: index)
            save()
        }else {
            print("project not found.")
        }
    }
}

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

        }
        .onChange(of: project) { newValue in
            print("\(newValue)")
        }
    }
}

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

        }
    }
}

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
                projectsCollapsed.toggle()
            } label: {
                projectsCollapsed ? Image(systemName: "arrow.up") : Image(systemName: "arrow.down")
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
                    Button {
                        projectMan.load()
                    } label: {
                        Text("Load")
                    }
                    Button {
                        showingNew = true
                    } label: {
                        Text("New ...")
                    }
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
            else {
                
            }
            Divider()
        }
        .onAppear {
            projectMan.load()
        }
        
    }
}

struct ContentView: View {
    var sectionPadding:CGFloat = 25
    
    @AppStorage("cwdp") var workingDirPath = ""
    @AppStorage("mmsdkpath") var mmsdkPath = ""
    @AppStorage("logTimestamps") var logTimestamps = false
    
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
    
    var commands: some View {
        VStack(alignment:.leading) {
            HStack {
                Text("MMSDK Commands")
                    .font(.title)
                Button {
                    commandsCollapsed.toggle()
                } label: {
                    commandsCollapsed ? Image(systemName: "arrow.up") : Image(systemName: "arrow.down")
                }

            }
            if !commandsCollapsed {
                Toggle("Timestamps", isOn: $logTimestamps)
                    .padding([.leading], sectionPadding)
                HStack {
                    Group {
                        
                        ForEach(Runner.MMSDKCommands.allCases, id:\.self) { command in
                            Button {
                                runner.run(command, for:selectedProject)
                            } label: {
                                Text(command.label)
                            }
                            .disabled(!hasContext(for: command))
                            //
                        }
                    }
                }
                .padding([.leading], sectionPadding)
                outputView
            }
        }
    }
    
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
                Button {
                    outputCollapsed.toggle()
                } label: {
                    outputCollapsed ? Image(systemName: "arrow.up") : Image(systemName: "arrow.down")
                }

            }
            if !outputCollapsed {
                TextEditor(text:$runner.output)
                    .padding([.leading],sectionPadding)
            }
            Divider()
        }
        
    }
    
    var body: some View {
        
        VStack {
            VStack(alignment:.leading) {
                ProjectListView(selectedProject: $selectedProject)
                SerialPortView()
                Divider()
                commands
            }
            
            HSplitView {
                    FSView(project: selectedProject,
                           projectWatcher: watcher,
                           fileSelections: fileSelections)
                if let p = selectedProject {
                    EditorView(fileSelections: fileSelections,
                               project: p)
                }
            }
            .padding([.bottom],0)
        }
    }
}
