//
//  ProjectManager.swift
//  MamachineGUI
//
//  Created by Jimmy Hough Jr on 1/3/23.
//

import SwiftUI
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
