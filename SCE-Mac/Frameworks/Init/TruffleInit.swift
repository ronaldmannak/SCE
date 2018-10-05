//
//  TruffleInit.swift
//  SCE
//
//  Created by Ronald "Danger" Mannak on 10/4/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation

struct TruffleInit: ProjectInitProtocol {
    
//    init(templateName: String?, installScript: String, project: Project, copyFiles: [CopyFile]? = nil) {
//        self.templateName = templateName
//        self.installScript = installScript
//        self.project = project
//        self.copyFiles = copyFiles
//    }
    
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
                finished()
            }
            
            guard let copyFiles = self.copyFiles else { return }
            for file in copyFiles {
                self.copy(file: file)
            }
        }
        
        var arguments: [String] = [project.baseDirectory!.absoluteURL.path, project.name]
        if let templateName = templateName {
            arguments.append(templateName)
        }
        //        scriptTask = try ScriptTask(script: project.framework.initScript, arguments: arguments, output: output, finished: f)
        scriptTask = try ScriptTask(script: "", arguments: arguments, output: output, finished: f)
        scriptTask.run()
        return scriptTask
    }
    
    
    func saveProjectFile() {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        do {
            let data = try encoder.encode(self.project)
            FileManager.default.createFile(atPath: self.project.projectFileURL.path, contents: data, attributes: nil)
        } catch {
            print(error)
            assertionFailure()
        }
    }
}
