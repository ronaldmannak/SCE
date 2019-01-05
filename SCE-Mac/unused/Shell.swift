//
//  Shell.swift
//  SCE
//
//  Created by Ronald "Danger" Mannak on 10/4/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation


/*
 Can we do something like:
 
 $ shell.command env=HOME=...\nPATH=... cmd=etherlime args= -r -v ...
 
 and then in the generic script:
 
 if [[ "$env" is not nil]] <- if that is even needed
 $env
 fi
 ...
 
 */


/// Based on: https://atom.io/packages/build
/// Use for future refactoring to general purpose 
struct Shell: Codable {
    
    /// E.g. etherlime, should be raw value of framework enum
    let framework: String
    
    /// Minimum version
    let version: String
    
    /// Command, e.g. "etherlime"
    let cmd: String
    
    /// Target, e.g. "projectname"
    let target: String
    
    /// Arguments, e.g. "-r"
    let args: [String]
    
    /// Working directory
    let workingDirectory: String
    
    /// Array of environment array, e.g. HOME=....
    let env: [String]
    
    /// Name of the file used for structured output
    let outputFile: String
    
    /// Regex match for error filename, line and column
    let errorMatch: [String]
    
    /// Regex match for warning filename, line and column
    let warningMatch: [String]
    
    /// Key mapping, e.g. "Cmd-R"
    let keymap: String?
    
    /// command name, e.g. "Product:Run"
    let commandName: String?
    
    /// Targets
    // TODO:
}
