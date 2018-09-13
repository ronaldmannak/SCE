//
//  Project.swift
//  SCE-Mac
//
//  Created by Ronald "Danger" Mannak on 8/16/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation

struct Project: Codable {
    
    /// Name of the project, e.g. ProjectName
    let name: String
    
    /// URL of the .comp project file E.g. ~/Projects/ProjectName/ProjectName.comp
    var projectFileURL: URL {
        return workDirectory.appendingPathComponent("\(name).comp")
    }
    
    /// Parent directory of the project, e.g. ~/Projects (not ~/Projects/ProjectName)
    let baseDirectory: URL
    
    /// E.g. ~/Projects/ProjectName
    var workDirectory: URL {
        return baseDirectory.appendingPathComponent(name, isDirectory: true)        
    }
    
    var lastOpenFile: String?

    
//    let platform: Platform
//    let tool: ?? e.g. Truffle
//    let restoreState ??
}

class ProjectCreator: Codable {
    
    let templateName: String
    let installScript: String
    let project: Project
    let copyFiles: [CopyFile]?
    
    var scriptTask: ScriptTask!
    
    private enum CodingKeys: String, CodingKey {
        case templateName
        case installScript
        case project
        case copyFiles
    }
    
    init(templateName: String, installScript: String, project: Project, copyFiles: [CopyFile]? = nil) {
        self.templateName = templateName
        self.installScript = installScript
        self.project = project
        self.copyFiles = copyFiles
    }
    
    
    /// Creates a new project on disk
    ///
    /// - Parameters:
    ///   - output: <#output description#>
    ///   - finished: <#finished description#>
    /// - Returns: <#return value description#>
    /// - Throws: <#throws value description#>
    func create(output: @escaping (String)->Void, finished: @escaping () -> Void) throws -> ScriptTask {
        
        // Closure copying custom files from bundle to project directory
        let f: () -> Void = {
            defer { finished() }
            let fileManager = FileManager.default
            guard let copyFiles = self.copyFiles else { return }
            for file in copyFiles {
                guard let source = Bundle.main.url(forResource: file.filename, withExtension: nil) else {
                    assertionFailure() // Source file does not exist in bundle
                    continue
                }
                let destination = self.project.workDirectory.appendingPathComponent(file.destination).appendingPathComponent(file.filename)
                do {
                    try fileManager.copyItem(at: source, to: destination)
                } catch {
                    print("****** \(error.localizedDescription) *****")
                    print("From: \(source.path)")
                    print("To: \(destination.path)")
                    assertionFailure()
                }
            }
            
            // Save initial project file to disk, so PreparingViewController can open it
            let encoder = PropertyListEncoder()
            encoder.outputFormat = .xml
            do {
                let data = try encoder.encode(self.project)
                fileManager.createFile(atPath: self.project.projectFileURL.path, contents: data, attributes: nil)
            } catch {
                print(error)
                assertionFailure()
            }
        }
        
        scriptTask = try ScriptTask(script: "TruffleInit", arguments: [project.baseDirectory.absoluteURL.path, project.name, templateName], output: output, finished: f)
        scriptTask.run()
        return scriptTask
    }
}

struct CopyFile: Codable {
    let filename: String
    let destination: String
}
