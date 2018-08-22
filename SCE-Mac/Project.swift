//
//  Project.swift
//  SCE-Mac
//
//  Created by Ronald "Danger" Mannak on 8/16/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation

struct Project: Codable {
    
    let name: String
    
    /// Parent directory of the project, e.g. ~/Projects (not ~/Projects/ProjectName)
    let baseDirectory: URL
    
    /// E.g. ~/Projects/ProjectName
    var workDirectory: URL {
        return baseDirectory.appendingPathComponent(name, isDirectory: true)        
    }
    
    // last open file, cursor position, etc
}

class ProjectCreator: Codable {
    let templateName: String
    let installScript: String
    let project: Project
    let copyFiles: [String: URL]
    
    // TODO: truffle vs Embark
    
    var scriptTask: ScriptTask!
    
    private enum CodingKeys: String, CodingKey {
        case templateName
        case installScript
        case project
        case copyFiles
    }
    
    // install additional files [source, destination]
    // default open first file
    
    init(templateName: String, installScript: String, project: Project) {
        self.templateName = templateName
        self.installScript = installScript
        self.project = project
        self.copyFiles = [
            "TutorialToken.sol": project.workDirectory.appendingPathComponent("contracts"),
            "2_deploy_contracts.js": project.workDirectory.appendingPathComponent("migrations"),
        ]

    }
    
    func create(output: @escaping (String)->Void, finished: @escaping () -> Void) throws -> ScriptTask {
        
        let f: () -> Void = {
            let fileManager = FileManager.default
            let keys = Array(self.copyFiles.keys)
            for key in keys {
                if let url = Bundle.main.url(forResource: key, withExtension: nil), let destination = self.copyFiles[key] {
                    do {
                    try fileManager.copyItem(at: url, to: destination.appendingPathComponent(key))
                    } catch {
                        print("****** \(error.localizedDescription) *****")
                        print("From: \(url)")
                        print("To: \(self.copyFiles[key]!)")
                        assertionFailure()
                    }
                } else {
                    assertionFailure()
                }
            }
            finished()
        }
        
        scriptTask = try ScriptTask(script: "TruffleInit", arguments: [project.baseDirectory.absoluteURL.path, project.name, templateName], output: output, finished: f)
        scriptTask.run()
        return scriptTask
    }
    
//    static func truffleInit(path: URL, projectname: String, templatename: String, output: @escaping (String)->Void, finished: @escaping () -> Void) -> ScriptTask {
//        //        let task = ScriptTask(script: "TruffleInit", arguments: [""], path: path, output: output, finished: finished)
//        let task = ScriptTask(script: "listdir", arguments: [""], path: path, output: output, finished: finished)
//        task.run()
//        return task
//    }
}
