//
//  AboutView.swift
//  MamachineGUI
//
//  Created by Jimmy Hough Jr on 1/3/23.
//

import SwiftUI
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
