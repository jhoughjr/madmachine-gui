//
//  MamachineGUIApp.swift
//  MamachineGUI
//
//  Created by Jimmy Hough Jr on 12/27/22.
//

import SwiftUI

@main
struct MamachineGUIApp: App {
    @ObservedObject var projectManager = ProjectManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
