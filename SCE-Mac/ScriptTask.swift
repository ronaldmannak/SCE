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
    
    static var queue = DispatchQueue(label: "ScriptTaskQueue", qos: .background) 
    
    var task = Process()
    let outputPipe = Pipe()
    
    let launchpath: String
    var notification: NSObjectProtocol!
    let arguments: [String]
    
    var output: ((String) -> Void)?
    var finished: ((Int) -> Void)?
    
    init(script: String, ext: String = "command", path: URL? = nil, arguments: [String], output: @escaping (String)->Void, finished: @escaping (Int) -> Void) throws {
        
        if let path = path {
            launchpath = path.appendingPathComponent(script, isDirectory: false).appendingPathExtension(ext).absoluteString
        } else if let path = Bundle.main.path(forResource: script, ofType: ext) {
            launchpath = path
        } else {
            throw CompositeError.fileNotFound("File not found")
        }
        self.arguments = arguments
        self.output = output        // TODO: Do we also need to route stderr?
        self.finished = finished
    }
    
    deinit {
        NotificationCenter.default.removeObserver(notification)
    }
    
    func run() {
        
        ScriptTask.queue.async {
            
            self.task.launchPath = self.launchpath
            self.task.arguments = self.arguments
            self.task.environment = ["PATH": "/usr/local/bin/:/usr/bin:/bin:/usr/sbin:/sbin"]                    
            
            // Handle termination
            self.task.terminationHandler = { task in
                let exitStatus = task.terminationStatus
                DispatchQueue.main.async(execute: { self.finished?(Int(exitStatus)) })
            }
            
            // Handle output
            self.captureStandardOutput()
            
            self.task.launch()
            self.task.waitUntilExit()
        }
    }
    
    // TODO: add enum whether output it stdOut, stdErr or entered command, so console can color code the output
    func captureStandardOutput() {
        
        task.standardOutput = outputPipe
        task.standardError = outputPipe
        
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
    
    /// Convenience initializer for generic Execute.command script
    ///
    /// - Parameters:
    ///   - directory: directory where script will be run (e.g. project directory)
    ///   - path: Add custom path environment variable
    ///   - commands: Commands to execute. Quotes will be added
    ///   - output: Output of the script will be send here
    ///   - finished: Called when finished with exit code
    /// - Throws: forwarded exception from designated initializer
    convenience init(directory: String, path: String? = nil, commands: [String], output: @escaping (String)->Void, finished: @escaping (Int) -> Void) throws {
        
        var arguments = [String]()
        arguments.append("-d \(directory.escapedSpaces)")
        if let path = path { arguments.append("-p \(path.escapedSpaces)") }
        
        for command in commands {
            arguments.append("\"\(command)\"")
        }
        try self.init(script: "Execute", arguments: arguments, output: output, finished: finished)
    }
}
