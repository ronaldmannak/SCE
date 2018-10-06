//
//  TruffleInit.swift
//  SCE
//
//  Created by Ronald "Danger" Mannak on 10/4/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation

class TruffleInit: ProjectInitProtocol {    
    
    let project: Project
    
    let template: Template?
    
    let baseDirectory: URL
    
    var projectFileURL: URL {
        return workDirectory.appendingPathComponent(project.name).appendingPathExtension("comp")
    }
    
    var workDirectory: URL {
        return baseDirectory.appendingPathComponent(project.name)
    }
    
    private (set) var scriptTask: ScriptTask? = nil
    
    let stdOutputLines: Int
    
    required init(project: Project, baseDirectory: URL, template: Template?, info: Any?) throws {
        self.template = template
        self.project = project
        self.baseDirectory = baseDirectory
        
        self.stdOutputLines = 8
    }
    
    required init(projectInit: ProjectInitProtocol, info: Any?) {
        self.template = projectInit.template
        self.project = projectInit.project
        self.baseDirectory = projectInit.baseDirectory
        self.stdOutputLines = projectInit.stdOutputLines
        
        // TODO: info = ...
    }
    
    
    
    /// Creates a new project on disk
    ///
    /// - Parameters:
    ///   - output: <#output description#>
    ///   - finished: <#finished description#>
    /// - Returns: <#return value description#>
    /// - Throws: <#throws value description#>
    func create(output: @escaping (String)->Void, finished: @escaping () -> Void) throws -> ScriptTask {
        
        // Create project directory
        let fileManager = FileManager.default
        try fileManager.createDirectory(at: workDirectory, withIntermediateDirectories: false)
        
        // Closure copying custom files from bundle to project directory
        // Will be executed after scriptTaks finishes
        let f: () -> Void = {
            
            defer {
                // Save initial project file to disk, so PreparingViewController can open it
                self.saveProjectFile()
                self.scriptTask = nil
                finished()
            }
            
            if let copyFiles = self.template?.copyFiles {
                for file in copyFiles {
                    do {
                        try self.copy(file: file)
                    } catch {
                        print(error)
                        assertionFailure()
                    }
                }
            }
        }
        
        var arguments: [String] = [workDirectory.path, project.name]
        if let templateName = template?.name {
            arguments.append(templateName)
        }
        
//        let scriptTask = try ScriptTask(script: project.framework.initScript, arguments: arguments, output: output, finished: f)
        scriptTask = try ScriptTask(script: "TruffleInit", arguments: arguments, output: output, finished: f)
        scriptTask!.run()
        return scriptTask!
    }
    
    
    func saveProjectFile() {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        do {
            let data = try encoder.encode(self.project)
            FileManager.default.createFile(atPath: projectFileURL.path, contents: data, attributes: nil)
        } catch {
            print(error)
            assertionFailure()
        }
    }
}
