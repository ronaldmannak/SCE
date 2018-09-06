//
//  Dependency.swift
//  SCE-Mac
//
//  Created by Ronald "Danger" Mannak on 9/5/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation


/// Dependency is an application Composite depends on, e.g. truffle
struct Dependency: Codable {
    
    /// Filename
    let name: String
    
    /// Location set by user. Will be added to Bash $PATH
    let customLocation: String?
    
    /// Default location of the dependency
    let defaultLocation: String
    
    /// Minimum version
    let minimumVersion: String?
    
    /// Command to display version
    let versionCommand: String
    
    /// Regex parsing of version obtained with versionCommand
    let versionRegex: String?
    
    /// Command to install depedency
    let installCommand: String?
    
    /// Command to upgrade dependency to latest version
    let upgradeCommand: String?
    
    /// Just for reminding what
    let comment: String?
}

extension Dependency {
    
    var location: String {
        return customLocation ?? defaultLocation
    }
    
    var versionMatch: Bool {
        // remove first character if character is v
        // split first word into array of three ints
        return true
    }
}


// npm ganache truffle
// Ethlint

// Solium:

//npm install -g solium
//solium -V
