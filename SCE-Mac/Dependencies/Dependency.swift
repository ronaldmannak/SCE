//
//  Dependency.swift
//  SCE-Mac
//
//  Created by Ronald "Danger" Mannak on 9/5/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation
import Cocoa


/// Dependency is an application Composite depends on, e.g. truffle
class Dependency: Codable {
    
    /// Filename
    let name: String
    
    /// Default location of the dependency
    let defaultLocation: String
    
    /// Version of this dependency is forwarded to the framework
    let isFrameworkVersion: Bool
    
    /// Command to display version
    let versionCommand: String?
        
    /// Command to install depedency
    let installCommand: String?
    
    /// If there's no command line install, use http link
    let installLink: String?
    
    /// Command to upgrade dependency to latest version
    let updateCommand: String?
    
    /// Command to check if dependency is up to date
    let outdatedCommand: String?
    
    /// Just for reminding what
    let comment: String?
    
    /// Some tools are not required. E.g. Brew is not always needed, as some tools
    /// can be installed without Brew. If all tools are installed, but not Brew, Composite
    /// will ignore any tool that has required set to false
    let required: Bool
    
    ///
//    init(name: String, customLocation: String?, defaultLocation: String, isFrameworkVersion: Bool, versionCommand: String?, installCommand: String?, installLink: String?, updateCommand: String?, comment: String, required: Bool, versionNumber: String?) {
//        self.name = name
//        self.customLocation = customLocation
//        self.defaultLocation = defaultLocation
//        self.isFrameworkVersion = isFrameworkVersion
//        self.versionCommand = versionCommand
//        self.installCommand = installCommand
//        self.installLink = installLink
//        self.updateCommand = updateCommand
//        self.comment = comment
//        self.required = required
//        self.versionNumber = versionNumber
//    }
}


