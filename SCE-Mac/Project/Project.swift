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
    
//    var frameworkInterface: FrameworkInterfaceProtocol? {
//        return nil
////        return FrameworkInterface(platformName: platformName, frameworkName: frameworkName)
//    }
}


