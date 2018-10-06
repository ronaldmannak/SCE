//
//  FrameworkInitProtocol.swift
//  SCE
//
//  Created by Ronald "Danger" Mannak on 10/4/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation

struct CopyFile: Codable {
    let filename: String
    let destination: String
    let renameFileToProjectName: Bool
}

protocol ProjectInitProtocol {
    
    var project: Project { get }
    
    
    var template: Template? { get }
    
    
    /// URL of the .comp project file E.g. ~/Projects/ProjectName/ProjectName.comp
    /// Default implementation provided
    var projectFileURL: URL { get }
    
    
    /// Parent directory of the project, e.g. ~/Projects (not ~/Projects/ProjectName)
    /// Default implementation provided
    var baseDirectory: URL { get }
    
    
    /// E.g. ~/Projects/ProjectName
    /// Default implementation provided
    var workDirectory: URL { get }
    
    
    ///
    var scriptTask: ScriptTask? { get }
    
    
    /// Used to calculate progress bar in PreparingViewController
    var stdOutputLines: Int { get }
    
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - template: <#template description#>
    ///   - project: <#project description#>
    ///   - info: <#info description#>
    /// - Throws: <#throws value description#>
    init(project: Project, baseDirectory: URL, template: Template?, info: Any?) throws
    
    init(projectInit: ProjectInitProtocol, info: Any?)
    
    /// Creates a new project on disk
    ///
    /// - Parameters:
    ///   - output: <#output description#>
    ///   - finished: <#finished description#>
    /// - Returns: <#return value description#>
    /// - Throws: <#throws value description#>
    func create(output: @escaping (String)->Void, finished: @escaping () -> Void) throws -> ScriptTask 
    
    /// Default implementation provided
    func copy(file: CopyFile) throws
}

extension ProjectInitProtocol {
    
    var baseDirectory: URL {
        return workDirectory.deletingLastPathComponent()
    }
    
    var workDirectory: URL {
        return projectFileURL.deletingLastPathComponent()
    }
    
    func copy(file: CopyFile) throws {
        
        guard let source = Bundle.main.url(forResource: file.filename, withExtension: nil) else {
            assertionFailure() // Source file does not exist in bundle
            return
        }
        
        let filename: String
        if file.renameFileToProjectName == true {
            let ext = (file.filename as NSString).pathExtension
            filename = project.name + "." + ext
        } else {
            filename = file.filename
        }
        
        let destination = workDirectory.appendingPathComponent(file.destination).appendingPathComponent(filename)
        try FileManager.default.copyItem(at: source, to: destination)
    }
}
