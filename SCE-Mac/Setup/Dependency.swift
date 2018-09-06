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
    let versionCommand: String?
    
    /// Regex parsing of version obtained with versionCommand
    let versionRegex: String?
    
    /// Command to install depedency
    let installCommand: String?
    
    /// If there's no command line install, use http link
    let installLink: String?
    
    /// Command to upgrade dependency to latest version
    let upgradeCommand: String?
    
    /// Just for reminding what
    let comment: String?
    
}

extension Dependency {
    
    
    /// The full URL of the app (directory and app)
    var url: URL {
        let url = URL(fileURLWithPath: directory).appendingPathComponent(name)
        return url
    }
    
    /// The directory path of the dependency
    var directory: String {
        guard let customLocation = customLocation, customLocation.isEmpty == false else {
            return defaultLocation
        }
        return customLocation
    }

}

extension Dependency: CustomStringConvertible {

    var description: String {
        return name.capitalizedFirstChar().replacingOccurrences(of: ".app", with: "")
    }
    
}

// File validation
extension Dependency {
    
    /// True if file exists at customLocation or defaultLocation
    var isInstalled: Bool {
        print("checking path \(url.path)")
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    /// Fetches the version as returned by the dependency itself
    ///
    /// - Parameter version: Closure returning the version number
    /// - Throws: ScriptTask error
    func fileVersion(version:@escaping (String) -> ()) throws {
        guard let versionCommand = versionCommand else {
            version("")
            return
        }
        let task = try ScriptTask(script: "General", arguments: [versionCommand], output: { output in
            
            // TODO: Apply regex
            version(output)
        }) {}
        task.run()
    }
    
    var versionMatch: Bool {
        return true
    }
    
    
    /// TODO: this doesn't work. No output. $PATH issue?
    /// https://unix.stackexchange.com/questions/85249/why-not-use-which-what-to-use-then
    ///
    /// - Parameter completion: Script output
    /// - Throws: FileNotFound error when the script (<script.command>) is not found
    func suggestLocation(completion: (String) -> ()) throws {
        let task = try ScriptTask(script: "Which", arguments: ["brew"], output: { output in
            print(output)
        }) {}
        task.run()
    }
    
}

