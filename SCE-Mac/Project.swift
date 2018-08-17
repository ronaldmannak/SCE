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
    var workDirectory: String {
        let url = baseDirectory.appendingPathComponent(name, isDirectory: true)
        return url.absoluteString
    }
    
    // last open file, cursor position, etc
}

struct ProjectCreator: Codable {
    let templateName: String
    let installScript: String
    let project: Project
    
    // TODO: truffle vs Embark
    
    var scriptTask: ScriptTask!
    
    private enum CodingKeys: String, CodingKey {
        case templateName
        case installScript
        case project
    }
    
    // install additional files [source, destination]
    // default open first file
    
    func create(output: @escaping (String)->Void, finished: @escaping () -> Void) {
        
        scriptTask = ScriptTask(script: "TruffleInit", arguments: [project.baseDirectory.absoluteURL.path], path: <#T##URL#>, output: output, finished: finished)
    }
    
//    static func truffleInit(path: URL, projectname: String, templatename: String, output: @escaping (String)->Void, finished: @escaping () -> Void) -> ScriptTask {
//        //        let task = ScriptTask(script: "TruffleInit", arguments: [""], path: path, output: output, finished: finished)
//        let task = ScriptTask(script: "listdir", arguments: [""], path: path, output: output, finished: finished)
//        task.run()
//        return task
//    }
}
