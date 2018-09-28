//
//  ProjectDirectoryCreator.swift
//  SCE
//
//  Created by Ronald "Danger" Mannak on 9/28/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation

struct CopyFile: Codable {
    let filename: String
    let destination: String
    // let rename: String ?
}


/// Creates the project directory and files
class ProjectDirectoryCreator { //: Codable {
    
    let templateName: String?
    
    let installScript: String
    
    let project: Project
    
    let copyFiles: [CopyFile]?
    
    var scriptTask: ScriptTask!
    
//    private enum CodingKeys: String, CodingKey {
//        case templateName
//        case installScript
//        case project
//        case copyFiles
//    }
//
    
    init(templateName: String?, installScript: String, project: Project, copyFiles: [CopyFile]? = nil) {
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

            guard let copyFiles = self.copyFiles else { return }
            for file in copyFiles {
                self.copy(file: file)
            }
            
            // Save initial project file to disk, so PreparingViewController can open it
            self.saveProjectFile()
        }
        var arguments: [String] = [project.baseDirectory.absoluteURL.path, project.name]
        if let templateName = templateName {
            arguments.append(templateName)
        }
        scriptTask = try ScriptTask(script: project.framework.initScript, arguments: arguments, output: output, finished: f)        
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
    
    
    func copy(file: CopyFile) {
        guard let source = Bundle.main.url(forResource: file.filename, withExtension: nil) else {
            assertionFailure() // Source file does not exist in bundle
            return
        }
        let destination = self.project.workDirectory.appendingPathComponent(file.destination).appendingPathComponent(file.filename)
        do {
            try FileManager.default.copyItem(at: source, to: destination)
        } catch {
            print("****** \(error.localizedDescription) *****")
            print("From: \(source.path)")
            print("To: \(destination.path)")
            assertionFailure()
        }
    }
}


