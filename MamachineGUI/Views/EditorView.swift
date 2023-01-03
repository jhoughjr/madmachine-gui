//
//  EditorView.swift
//  MamachineGUI
//
//  Created by Jimmy Hough Jr on 1/3/23.
//

import SwiftUI
import CodeEditorView

struct EditorView:View {
    @State private var text:     String                = "My awesome code..."
    @State private var position: CodeEditor.Position  = CodeEditor.Position()
    @State private var messages: Set<Located<Message>> = Set()

    @State var checksum = ""
    
    @ObservedObject var fileSelections:FileSelections
    @State var project:ProjectManager.Project
    
    @Environment(\.colorScheme) private var colorScheme: ColorScheme

    var editorCommands: some View {
        HStack {
            Button {
                if  !fileSelections.selectedEditorFile.isEmpty {
                    
                    let url = URL(filePath: fileSelections.selectedEditorFile)
                    do {
                        try $text.wrappedValue.data(using: .utf8)?.write(to: url)
                        DispatchQueue.main.async {
                            $checksum.wrappedValue = $text.wrappedValue.md5
                        }
                        
                    }
                    catch {
                        print(error)
                    }
                }
            } label: {
                Text("Save")
            }
            .disabled(checksum == text.md5)
        }
    }
    var body: some View {
        VStack(alignment:.leading) {
            Text("Code Editor")
                .font(.title)
            editorCommands
            CodeEditor(text: $text,
                       position: $position,
                       messages: $messages,
                       language: .swift)
              .environment(\.codeEditorTheme,
                           colorScheme == .dark ? Theme.defaultDark : Theme.defaultLight)
        }
        .onChange(of: fileSelections.selectedEditorFile,
                  perform: { newValue in

            let path = newValue
            
            if let d = FileManager.default.contents(atPath: path) {
                
                let loadedText = String(data: d,
                                        encoding: .utf8) ?? "Couldnt load utf8"
                
                $text.wrappedValue = loadedText
                checksum = loadedText.md5
            }else {
                print("no data at  \(path)")
            }
        })
     
    }
}
