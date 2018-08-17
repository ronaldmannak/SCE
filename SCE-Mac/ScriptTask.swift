//
//  ScriptTask.swift
//  SCE-Mac
//
//  Created by Ronald "Danger" Mannak on 8/2/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation


protocol ScriptTaskProtocol {
    func taskFinished(_ task: ScriptTask)
    func task(_ task: ScriptTask, output: String)
}

/**
 
 See: https://www.raywenderlich.com/125071/nstask-tutorial-os-x
 */
class ScriptTask: NSObject {
    
    var task = Process()
    let outputPipe = Pipe()
    
//    let script: String // Script filename
    let launchpath: URL
    var notification: NSObjectProtocol!
    let launchpath: String
    let arguments: [String]
    
    var delegate: ScriptTaskProtocol?
    var output: ((String) -> Void)?
    var finished: (() -> Void)?
    
//    init(script: String, arguments: [String], path: URL, delegate: ScriptTaskProtocol) {
//
//    }
    
    init(script: String, launchpath: URL?, arguments: [String], output: @escaping (String)->Void, finished: @escaping () -> Void) {
//        self.script = script
//        self.launchpath = path.absoluteString
        
        guard let path = Bundle.main.path(forResource: script,ofType:"command") else {
            assertionFailure()
            return
        }
        launchpath = path
        
        self.arguments = arguments
        
        
        self.output = output
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
            
            // Handle termination
            self.task.terminationHandler = { task in
                DispatchQueue.main.async(execute: {
                    print("**** ScriptTask Finished ****")
                    self.delegate?.taskFinished(self)
                    self.finished?()
                })
            }
            
            // Handle output
            self.captureStandardOutput()
            
            self.task.launch()
            self.task.waitUntilExit()
        }
    }
    
    func captureStandardOutput() {
        
        self.task.standardOutput = outputPipe
        
        notification = NotificationCenter.default.addObserver(forName: .NSFileHandleDataAvailable, object: outputPipe.fileHandleForReading , queue: nil) {
            notification in
            
            let output = self.outputPipe.fileHandleForReading.availableData
            let outputString = String(data: output, encoding: String.Encoding.utf8) ?? ""
            
            DispatchQueue.main.async(execute: {
                print("**** ScriptTask output ****")
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
    
    /// For now, implement: https://truffleframework.com/tutorials/robust-smart-contracts-with-openzeppelin
//    static func truffleInit(path: URL, projectname: String, templatename: String, output: @escaping (String)->Void, finished: @escaping () -> Void) -> ScriptTask {
////        let task = ScriptTask(script: "TruffleInit", arguments: [""], path: path, output: output, finished: finished)
//        let task = ScriptTask(script: "listdir", arguments: [""], path: path, output: output, finished: finished)
//        task.run()
//        return task
//    }
}
