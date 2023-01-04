//
//  FileSelections.swift
//  MamachineGUI
//
//  Created by Jimmy Hough Jr on 1/3/23.
//

import SwiftUI
class FileSelections:ObservableObject {
    @Published var project:ProjectManager.Project? = nil {
        didSet {
            workingDIr = project?.workingDir ?? ""
        }
    }
    
    @Published var previousDirectory = ""
    
    @Published var selection = "" {
        didSet {
            print("selected \(selection)")
            var isDir:ObjCBool = false
            
            let path = selection
            print("Checking path \(path)")
            _ = FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
            if isDir.boolValue {
                previousDirectory = workingDIr
                workingDIr = path
                print("is dir")
                if let fs = try? FileManager.default.contentsOfDirectory(atPath: path) {
                    let foo = workingDIr.replacing("file://", with: "")
                    
                    currentDirContents = fs.map({"\(foo)/\($0)"})
                }else {
                    print("couldn't check")
                }
            }
            else {
                print("is file")
                let url = URL(filePath: path)
                if let fs = try? FileManager.default.contentsOfDirectory(atPath: url.deletingLastPathComponent().path()) {
                    
                    currentDirContents = fs
                }else {
                    print("couldn't check")
                }
                print("selected file, setting editorFIle")
                selectedEditorFile = selection
            }
        }
    }
    
    @Published var workingDIr = "" {
        didSet {
            print("workingDIr = \(workingDIr)")
        }
    }
    
    @Published var selectedEditorFile = "" {
        didSet {
            print("selectedEditorFile = \(selectedEditorFile)")
        }
    }
    
    @Published var currentDirContents = [String]() {
        didSet {
            print("currnt \(currentDirContents)")
        }
    }
}

