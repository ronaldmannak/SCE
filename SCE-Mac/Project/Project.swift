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
    
//    let interface: PlatformInterfaceProtocol
    
    /// Parent directory of the project, e.g. ~/Projects (not ~/Projects/ProjectName)
    let baseDirectory: URL
    
    /// E.g. ~/Projects/ProjectName
    var workDirectory: URL {
        return baseDirectory.appendingPathComponent(name, isDirectory: true)        
    }
    
    var lastOpenFile: String?
    
}


