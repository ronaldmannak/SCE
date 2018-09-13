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
        
    /// Command to install depedency
    let installCommand: String?
    
    /// If there's no command line install, use http link
    let installLink: String?
    
    /// Command to upgrade dependency to latest version
    let upgradeCommand: String?
    
    /// Just for reminding what
    let comment: String?
    
    /// Some tools are not required. E.g. Brew is not always needed, as some tools
    /// can be installed without Brew. If all tools are installed, but not Brew, Composite
    /// will ignore any tool that has required set to false
    let required: Bool
    
    fileprivate (set) var versionNumber: String?
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
//        print(FileManager.default.fileExists(atPath: url.path))
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    /// Fetches the version as returned by the dependency itself
    ///
    /// - Parameter version: Closure returning the version number
    /// - Throws: ScriptTask error
//    mutating func fileVersion(version:@escaping (String) -> ()) throws {
    func fileVersion(version:@escaping (String) -> ()) throws {
        
        // If this dependency doesn't have a version query command, return empty string
        guard let versionCommand = versionCommand else {
            version("")
            return
        }
        let homePath = FileManager.default.homeDirectoryForCurrentUser.path
        let task = try ScriptTask(script: "General", arguments: [versionCommand, homePath], output: { output in
            
            // Filter 1.0.1-rc1 type version number
            // Some apps return multiple lines, and this closure will be called multiple times.
            // Therefore, if no match if found, the output closure will not be called, since the
            // version number could be in the previous or next line.
            guard let regex = try? NSRegularExpression(pattern: "(\\d+)\\.(\\d+)\\.(\\d+)\\-?(\\w+)?", options: .caseInsensitive) else {
                version(output) // If somehow the regex fails, return the whole string
                return
            }

            let versions = regex.matches(in: output, options: [], range: NSRange(location: 0, length: output.count)).map {
                String(output[Range($0.range, in: output)!])
            }
            
            // Truffle replies with multiple version on multiple lines we and
            // might get the wrong version here in edge cases.
            guard let versionString = versions.first else { return }
            version(versionString)
            
//            guard versions.isEmpty == false else { return }
//
//            let string = versions.reduce("", { (result, string) -> String in
//                result.isEmpty ? string : result + " " + string
//            })
//
//            version(string)
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
    
    func install(output: @escaping (String) -> Void, finished: @escaping () -> Void) throws -> ScriptTask? {
        
        if let link = installLink, let url = URL(string: link) {
            finished()
            NSWorkspace.shared.open(url)            
        }
        
        if let installCommand = installCommand {
            let homePath = FileManager.default.homeDirectoryForCurrentUser.path
            let task = try ScriptTask(script: "General", arguments: [installCommand, homePath], output: { console in
                output(console)
            }) {
                finished()
            }
            return task
        }
        
        // TODO: if neither link or installCommand is set, finished() is never called
        return nil
    }
    
    func update(output: @escaping (String) -> Void, finished: @escaping () -> Void) throws -> ScriptTask? {
        
        if let link = installLink, let url = URL(string: link) {
            finished()
            NSWorkspace.shared.open(url)
        }
        
        if let updateCommand = upgradeCommand {
            let homePath = FileManager.default.homeDirectoryForCurrentUser.path
            let task = try ScriptTask(script: "General", arguments: [updateCommand, homePath], output: { console in
                output(console)
            }) {
                finished()
            }
            return task
        }
        return nil
    }
    
}

