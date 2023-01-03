//
//  ProjectWatcher.swift
//  MamachineGUI
//
//  Created by Jimmy Hough Jr on 1/3/23.
//

import Foundation
import SwiftUI

class ProjectWatcher:ObservableObject {
    @Published var workingFiles:[String] = [String]() {
        didSet {
            print("\(workingFiles)")
        }
    }
    
    func look(at:ProjectManager.Project) {
        let foo = at.workingDir.replacing("file://", with: "")
        print("looking at \(foo)")

        if let fs = try? FileManager.default.contentsOfDirectory(atPath: foo) {
            workingFiles = fs.map({"\(foo)\($0)"})
        }else {
            print("couldn't look")
        }
    }
    
}

