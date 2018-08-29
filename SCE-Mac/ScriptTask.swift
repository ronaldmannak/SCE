//
//  ScriptTask.swift
//  SCE-Mac
//
//  Created by Ronald "Danger" Mannak on 8/2/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation

/**
 
 See: https://www.raywenderlich.com/125071/nstask-tutorial-os-x
 */
class ScriptTask: NSObject {
    
    var task = Process()
    let outputPipe = Pipe()
    
    let launchpath: String
    var notification: NSObjectProtocol!
    let arguments: [String]
    
    var output: ((String) -> Void)?
    var finished: (() -> Void)?
    
    init(script: String, ext: String = "command", path: URL? = nil, arguments: [String], output: @escaping (String)->Void, finished: @escaping () -> Void) throws {
        
        if let path = path {
            launchpath = path.appendingPathComponent(script, isDirectory: false).appendingPathExtension(ext).absoluteString
        } else if let path = Bundle.main.path(forResource: script, ofType: ext) {
            launchpath = path
        } else {
            throw EditorError.fileNotFound("File not found")
        }
        self.arguments = arguments
        self.output = output        // TODO: Do we also need to route stderr?
        self.finished = finished
    }
    
    deinit {
        NotificationCenter.default.removeObserver(notification)
    }
    
    func run() {
        
        let taskQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        taskQueue.async {
            
            self.task.launchPath = self.launchpath
            self.task.arguments = self.arguments
            self.task.environment = ["PATH": "/usr/local/bin/:/usr/bin:/bin:/usr/sbin:/sbin"]                    
            
            // Handle termination
            self.task.terminationHandler = { task in
                DispatchQueue.main.async(execute: { self.finished?() })
            }
            
            // Handle output
            self.captureStandardOutput()
            
            self.task.launch()
            self.task.waitUntilExit()
        }
    }
    
    func captureStandardOutput() {
        
        task.standardOutput = outputPipe
//        task.standardError = outputPipe
        
        notification = NotificationCenter.default.addObserver(forName: .NSFileHandleDataAvailable, object: outputPipe.fileHandleForReading , queue: nil) {
            notification in
            
            let output = self.outputPipe.fileHandleForReading.availableData
            guard let outputString = String(data: output, encoding: String.Encoding.utf8), !outputString.isEmpty else { return }
            
            DispatchQueue.main.async(execute: {
                print(outputString)
                assert(self.output != nil)
                self.output?(outputString)
            })
            
            self.outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        }
        outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
    }
    
    func terminate() {
        task.terminate()
    }
}


extension ScriptTask {
    
    static func run(project: Project, output: @escaping (String)->Void, finished: @escaping () -> Void) throws -> ScriptTask {
        // TODO: Switch truffle vs Embark
        let task = try ScriptTask(script: "TruffleRun", arguments: [project.workDirectory.path], output: output, finished: finished)
        task.run()
        return task
    }
    
    static func webserver(project: Project, output: @escaping (String)->Void, finished: @escaping () -> Void) throws -> ScriptTask {
        // TODO: Switch truffle vs Embark
        let task = try ScriptTask(script: "TruffleWebserver", arguments: [project.workDirectory.path], output: output, finished: finished)
        task.run()
        return task
    }
    
    static func lint(project: Project, output: @escaping (String)->Void, finished: @escaping () -> Void) throws -> ScriptTask {
        let task = try ScriptTask(script: "SoliumTruffle", arguments: [project.workDirectory.path], output: output, finished: finished)
        task.run()
        return task
    }
    
    //    static func truffleInit(path: URL, projectname: String, templatename: String, output: @escaping (String)->Void, finished: @escaping () -> Void) -> ScriptTask {
    //        //        let task = ScriptTask(script: "TruffleInit", arguments: [""], path: path, output: output, finished: finished)
    //        let task = ScriptTask(script: "listdir", arguments: [""], path: path, output: output, finished: finished)
    //        task.run()
    //        return task
    //    }
}
