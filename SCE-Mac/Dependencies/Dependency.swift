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
    
    /// Location set by user. Will be added to Bash $PATH
    let customLocation: String?
    
    /// Default location of the dependency
    let defaultLocation: String
    
    /// Minimum version
    let minimumVersion: String?
    
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
    
    /// Just for reminding what
    let comment: String?
    
    /// Some tools are not required. E.g. Brew is not always needed, as some tools
    /// can be installed without Brew. If all tools are installed, but not Brew, Composite
    /// will ignore any tool that has required set to false
    let required: Bool
    
    /// Cached version of the version
    private (set) var versionNumber: String?
    
    private weak var installOperation: BashOperation? = nil
    
    private weak var updateOperation: BashOperation? = nil
    
    private enum CodingKeys: String, CodingKey {
        case name, customLocation, defaultLocation, minimumVersion, isFrameworkVersion, versionCommand, installCommand, installLink, updateCommand, comment, required
    }
    
    ///
    init(name: String, customLocation: String?, defaultLocation: String, minimumVersion: String?, isFrameworkVersion: Bool, versionCommand: String?, installCommand: String?, installLink: String?, updateCommand: String?, comment: String, required: Bool, versionNumber: String?) {
        self.name = name
        self.customLocation = customLocation
        self.defaultLocation = defaultLocation
        self.minimumVersion = minimumVersion
        self.isFrameworkVersion = isFrameworkVersion
        self.versionCommand = versionCommand
        self.installCommand = installCommand
        self.installLink = installLink
        self.updateCommand = updateCommand
        self.comment = comment
        self.required = required
        self.versionNumber = versionNumber
    }
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
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    
    /// <#Description#>
    ///
    /// - Returns: <#return value description#>
    func versionQueryOperation() -> BashOperation? {
        
        guard let versionCommand = versionCommand, isInstalled == true else {
            return nil
        }
        return try? BashOperation(directory: "~", commands: [versionCommand])
    }
    
    
    /// Run this after the operation has finished. Pass the operation's output property
    ///
    /// - Parameter output: <#output description#>
    /// - Returns: <#return value description#>
    func versionQueryParser(_ output: String) -> String {
        
        // Filter 1.0.1-rc1 type version number
        // Some apps return multiple lines, and this closure will be called multiple times.
        // Therefore, if no match if found, the output closure will not be called, since the
        // version number could be in the previous or next line.
        guard let regex = try? NSRegularExpression(pattern: "(\\d+)\\.(\\d+)\\.(\\d+)\\-?(\\w+)?", options: .caseInsensitive) else {
            return output
        }
        
        let versions = regex.matches(in: output, options: [], range: NSRange(location: 0, length: output.count)).map {
            String(output[Range($0.range, in: output)!])
        }
        
        // Some dependencies return multiple lines for their version information
        // Ignore lines where no version is found
        guard let versionString = versions.first else { return "" }
        self.versionNumber = versionString
        return versionString
    }
    
    
    /// TODO: this doesn't work. No output. $PATH issue?
    /// https://unix.stackexchange.com/questions/85249/why-not-use-which-what-to-use-then
    ///
    /// - Parameter completion: Script output
    /// - Throws: FileNotFound error when the script (<script.command>) is not found
//    func suggestLocation(completion: (String) -> ()) throws {
//        let task = try ScriptTask(script: "Which", arguments: ["brew"], output: { output in
//            print(output)
//        }) { exitStatus in
//            
//            guard exitStatus == 0 else {
//                let error = CompositeError.bashScriptFailed("Bash error")
//                let alert = NSAlert(error: error)
//                alert.runModal()
//                return
//            }
//        }
//        task.run()
//    }
    
    func install() throws -> BashOperation? {

        // Hardcoded edgecase for brew.
        // The brew installer needs to run as admin.
        if name == "brew" {
            installBrew()
            return nil
        }
        
        // If dependency is already installed, return nil
        guard isInstalled == false else { return nil }
        
        // If dependency needs to be downloaded from a web page and installed manually, open url
        if let link = installLink, let url = URL(string: link) {
            NSWorkspace.shared.open(url)
            return nil
        }
        
        // If there's no installCommand, do nothing
        guard let installCommand = installCommand else {
            return nil
        }
        
        return try BashOperation(directory: "~", commands: [installCommand])
    }
    
    
    /// TODO: Look into running task as root to install tools like Berw
    ///
    // See:
    /// https://developer.apple.com/library/archive/documentation/Security/Conceptual/SecureCodingGuide/Articles/AccessControl.html
    /// https://www.reddit.com/r/macprogramming/comments/3wuvmz/how_to_createrun_an_nstask_in_swift_with_sudo/
    /// https://www.cocoawithlove.com/2009/05/invoking-other-processes-in-cocoa.html
    /// AppleScript: http://nonsenseinbasic.blogspot.com/2013/03/mac-os-x-programming-running-nstask.html
    private func installBrew()  {
        
        let message = "Please install brew manually by copying the following text in MacOS terminal"
        let command = "/usr/bin/ruby -e \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)\""
        
        let alert = NSAlert()
        alert.messageText = message
        alert.informativeText = command
        alert.runModal()
    }
    
    func update() throws -> BashOperation? {
        
        guard isInstalled == true, let updateCommand = updateCommand, updateCommand.isEmpty == false else {
            return nil
        }
        
        return try BashOperation(directory: "~", commands: [updateCommand])
    }
    
    func isInstalling() -> Bool {
        if let i = installOperation, i.isExecuting == true { return true }
        if let u = updateOperation, u.isExecuting == true { return true }
        return false
    }
}

