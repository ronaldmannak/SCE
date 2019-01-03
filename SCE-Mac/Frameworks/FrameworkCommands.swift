//
//  FrameworkCommands.swift
//  SCE
//
//  Created by Ronald "Danger" Mannak on 1/2/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Foundation

/// Stores the available commands for a framework (e.g. Truffle or Tronbox)
/// properties are read from Dependencies.plist file
struct FrameworkCommands: Codable {
    
    struct InitCommands: Codable {
        let commands: [String]
        let createProjectDirectory: Bool
    }
    
    let initCommands: InitCommands
    
    let compile: String
    
    let cleanCompile: String?
    
    let deploy: String
    
    let cleanDeploy: String?
    
    let runTests: String
    
    let cleanRunTests: String?
    
    let console: String?
    
    let lint: String?
    
    let errorRegex: String?
    
    let warningRegex: String?
}
