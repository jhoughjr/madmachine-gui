//
//  Runner.swift
//  MamachineGUI
//
//  Created by Jimmy Hough Jr on 12/27/22.
//

import Foundation
import Cocoa
import SwiftUI
import SwiftSlash

class Runner:ObservableObject {

//    enum GitCommands:String, CaseIterable {
//        case gitInit
//        case clone
//        case pull
//        case push
//        case add
//        case checkout
//        case commit
//    }
    
    enum MiscCommands:String, CaseIterable {
        case openInXcode
    }
    
    enum MMSDKCommands:String, CaseIterable {
        case initializeProject
        case build
        case addHeader
        case download
        case clean
        case get
        case ci_build
        case host_test
        
        var label:String {
            switch self {
                
            case .initializeProject:
                return "Initialize"
            case .build:
                return "Build"
            case .addHeader:
                return "Add Header"
            case .download:
                return "Download"
            case .clean:
                return "Clean"
            case .get:
                return "Get"
            case .ci_build:
                return "CI Build"
            case .host_test:
                return "Host Test"
            }
        }
        var explanation:String {
            get {
                switch self {
                    
                case .initializeProject:
                    return "Initiaize a new project"
                case .build:
                    return "Build a project"
                case .addHeader:
                    return "Add header to bin file"
                case .download:
                    return "Download the target executable to the boards RAM/Flash/SD card"
                case .clean:
                    return "Clean project"
                case .get:
                    return "Get specified information, used by IDE"
                case .ci_build:
                    return "CI Build"
                case .host_test:
                    return "Test a project in host with SwiftIO mock"
                }
            }
        }
        
        // prepended with mmsdk path
        var launchString:String {
            get {
                switch self {
                    
                case .build:
                    return "usr/mm/mm build"
                case .clean:
                    return "usr/mm/mm clean"
                case .get:
                    return "usr/mm/mm get"
                case .initializeProject:
                    return "usr/mm/mm init "
                case .addHeader:
                    return "usr/mm/mm add_header"
                case .download:
                    return "usr/mm/mm download"
                case .ci_build:
                    return "usr/mm/mm ci-build"
                case .host_test:
                    return "usr/mm/mm host-test"
                }
            }
        }
        
        func initLaunchString(name:String,
                              type:String,
                              board:String,
                              verbose:Bool) -> String {
            launchString.appending("--name \(name) -t \(type) -b \(board) \(verbose ? "-v" : "")")
        }
    }
    
    @AppStorage("logTimestamps") var logTimestamps = false
    @AppStorage("cwdp") var workingDirPath = ""
    @AppStorage("mmsdkpath") var mmsdkPath = ""
    
    @Published var output = ""
    @Published var lines = [""]
    
    private func output(_ s:String) {
        var line = ""
        
        if logTimestamps {
            line += "\(Date()) - "
        }
        
        DispatchQueue.main.async {
            self.lines.insert(contentsOf: [line,s,"\n"], at: 0)
            self.output = self.lines.joined()
        }
    }
    
    func clearOutput() {
        DispatchQueue.main.async {
            self.lines.removeAll()
            self.output = ""
        }
    }
    

    func run(_ command:MMSDKCommands = .build,
             for project:ProjectManager.Project? = nil,
             with context:[String:String]? = nil) {
        print("running \(command) for \(project) with \(context)")
        let u = URL(string: mmsdkPath)
        let p = u!.path(percentEncoded: false)
        
        var launchString = ""
        
        if let proj = project {
            switch command {
                
            case .initializeProject:
                // should get verbosity from context via ui
                // rest is definted in the project really
                
                
                    launchString = command.initLaunchString(name: proj.name,
                                                            type: proj.type.rawValue,
                                                            board: proj.boardName.rawValue,
                                                            verbose: false)
                    launchString = "\(p)\(launchString)"
               
            case .build:
                launchString = "\(p)\(command.launchString)"
            case .addHeader:
                break
            case .download:
                launchString = "\(p)\(command.launchString)"
            case .clean:
                break
            case .get:
                break
            case .ci_build:
                break
            case .host_test:
                break
            }
        }else {
            launchString = "\(p)\(command.launchString)"
        }
        //th path to the external program you want to run
        
        let finalString = launchString // stops caprtured ref async issue
    
        Task {
            // display running commandline in output
            self.output(finalString)
           
            //define the command you'd like to run
            var zfsDatasetsCommand:Command = Command(bash:finalString)
            // set its working directory
            zfsDatasetsCommand.workingDirectory = URL(string: workingDirPath)!
            //pass the command structure to a new ProcessInterface. in this example, stdout will be parsed into lines with the lf byte, and stderr will be unparsed (raw data will be passed into the stream)
            let zfsProcessInterface = ProcessInterface(command:zfsDatasetsCommand,
                                                       stdout:.active(.lf),
                                                       stderr:.active(.unparsedRaw))
            //launch the process. if you are running many concurrent processes (using most of the available resources), this is where your process will be queued until there are enough resources to support the launched process.
            let _ = try await zfsProcessInterface.launch()
            
            // pass stdout data if any was passed to published output
            for await outputLine in await zfsProcessInterface.stdout {
                    guard let s = String(data:outputLine, encoding:.utf8) else {return}
                    output(s)
            }
            
            // pass stderr data if any was passed to published output
            for await stderrChunk in await zfsProcessInterface.stderr {
                guard let s = String(data:stderrChunk, encoding:.utf8) else {return}
                output(s)
            }
            
            // retreive the exit code of the process.
            let exitCode = try await zfsProcessInterface.exitCode()
            
                if (exitCode == 0) {
                    //do work based on success
                    output("Command SUCCEEDED")
                } else {
                    //do work based on error
                    output("ERROR \(exitCode)")
                }

        }
    }

    func run(_ command:MMSDKCommands = .build, context:[String:String]? = nil) {
        
        let u = URL(string: mmsdkPath)
        let p = u!.path(percentEncoded: false)
        
        var launchString = ""
        
        if let ctx = context {
            switch command {
                
            case .initializeProject:
                if let name = ctx["name"],
                   let type = ctx["type"],
                   let board = ctx["board"],
                   let verbose = ctx["verbose"] {
                    launchString = command.initLaunchString(name: name,
                                                            type: type,
                                                            board: board,
                                                            verbose: verbose.isEmpty)
                }
               
            case .build:
                break
            case .addHeader:
                break
            case .download:
                break
            case .clean:
                break
            case .get:
                break
            case .ci_build:
                break
            case .host_test:
                break
            }
        }else {
            launchString = "\(p)\(command.launchString)"
        }
        //th path to the external program you want to run
        
        let finalString = launchString // stops caprtured ref async issue
    
        Task {
            // display running commandline in output
            self.output(finalString)
           
            //define the command you'd like to run
            var zfsDatasetsCommand:Command = Command(bash:finalString)
            // set its working directory
            zfsDatasetsCommand.workingDirectory = URL(string: workingDirPath)!
            //pass the command structure to a new ProcessInterface. in this example, stdout will be parsed into lines with the lf byte, and stderr will be unparsed (raw data will be passed into the stream)
            let zfsProcessInterface = ProcessInterface(command:zfsDatasetsCommand,
                                                       stdout:.active(.lf),
                                                       stderr:.active(.unparsedRaw))
            //launch the process. if you are running many concurrent processes (using most of the available resources), this is where your process will be queued until there are enough resources to support the launched process.
            let _ = try await zfsProcessInterface.launch()
            
            // pass stdout data if any was passed to published output
            for await outputLine in await zfsProcessInterface.stdout {
                    guard let s = String(data:outputLine, encoding:.utf8) else {return}
                    output(s)
            }
            
            // pass stderr data if any was passed to published output
            for await stderrChunk in await zfsProcessInterface.stderr {
                guard let s = String(data:stderrChunk, encoding:.utf8) else {return}
                output(s)
            }
            
            // retreive the exit code of the process.
            let exitCode = try await zfsProcessInterface.exitCode()
            
                if (exitCode == 0) {
                    //do work based on success
                    output("Command SUCCEEDED")
                } else {
                    //do work based on error
                    output("ERROR \(exitCode)")
                }

        }
    }
    
    func run(_ command:MiscCommands = .openInXcode, ctx:String) {
        switch command {
        case .openInXcode:
            Task {
                // display running commandline in output
                print("opening \(ctx) in Xcode..")
                self.output("opening \(ctx) in Xcode..")
               
                //define the command you'd like to run
                let launch = """
                open \(ctx)
                """
                output(launch)
                print(launch)
                let zfsDatasetsCommand:Command = Command(bash:launch)
                
                // set its working directory
//                zfsDatasetsCommand.workingDirectory = URL(string: workingDirPath)!
                //pass the command structure to a new ProcessInterface. in this example, stdout will be parsed into lines with the lf byte, and stderr will be unparsed (raw data will be passed into the stream)
                let zfsProcessInterface = ProcessInterface(command:zfsDatasetsCommand,
                                                           stdout:.active(.lf),
                                                           stderr:.active(.unparsedRaw))
                //launch the process. if you are running many concurrent processes (using most of the available resources), this is where your process will be queued until there are enough resources to support the launched process.
                let _ = try await zfsProcessInterface.launch()
                
                // pass stdout data if any was passed to published output
                for await outputLine in await zfsProcessInterface.stdout {
                        guard let s = String(data:outputLine, encoding:.utf8) else {return}
                        output(s)
                }
                
                // pass stderr data if any was passed to published output
                for await stderrChunk in await zfsProcessInterface.stderr {
                    guard let s = String(data:stderrChunk, encoding:.utf8) else {return}
                    output(s)
                }
                
                // retreive the exit code of the process.
                let exitCode = try await zfsProcessInterface.exitCode()
                
                    if (exitCode == 0) {
                        //do work based on success
                        output("Command SUCCEEDED")
                    } else {
                        //do work based on error
                        output("ERROR \(exitCode)")
                    }

            }
        }
    }
}
