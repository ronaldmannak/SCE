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

    
    /// Interface
    let platformName: String
    
    
    let frameworkName: String
    
    
    // TODO: add
    var lastOpenFile: String?
    
    
    init(name: String, platformName: String, frameworkName: String, lastOpenFile: String?) {
        self.name = name
        self.platformName = platformName
        self.frameworkName = frameworkName
        self.lastOpenFile = lastOpenFile?.replaceOccurrencesOfProjectName(with: name)
    }
}


