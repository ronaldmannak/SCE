//
//  DependencySetup.swift
//  SCE-Mac
//
//  Created by Ronald "Danger" Mannak on 9/5/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation

class DependencySetup {
    
    private let filename = "Dependencies.plist"
    private let folder: URL!
    private let dependenciesFile: URL!
    private let fileManager = FileManager.default
    private static let reverseDNSName = "com.composite.composite"
    
    func needsSetupUI() -> Bool {
        return true
    }
    
    
    /// <#Description#>
    ///
    /// - Throws:   Forwards FileManager error
    init() throws {
        
        // Set path to app's Application Support directory
        guard let support = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            throw EditorError.directoryNotFound("Application Support")
        }
        folder = support.appendingPathComponent(DependencySetup.reverseDNSName)
        dependenciesFile = folder.appendingPathComponent(filename)
    }
    
    /// <#Description#>
    ///
    /// - Parameter platform: platform to be loaded, e.g. .ethereum
    /// - Parameter overwrite:
    /// - Returns:  True if this is a new install
    /// - Throws:   Forwards FileManager error, or fileNotFound in case a file doesn't exist in the bundle
    ///             or directoryNotFound if no Application Support directory was found
    ///             or Codable error
    func setup(_ platform: Platform, overwrite: Bool = false) throws { //}-> [DependencyPlatform] {
        
        // Check if Application Support directory exists.
        // If not, create it.
        var isDirectory = ObjCBool(booleanLiteral: false)
        let appDirectoryExists = fileManager.fileExists(atPath: folder.path, isDirectory: &isDirectory)
        if appDirectoryExists == true && isDirectory.boolValue == false {
            try fileManager.removeItem(at: folder)
            try setupNewInstall()
        } else if appDirectoryExists == false {
            try setupNewInstall()
        }
        
        // Check if Dependencies.plist exists in Application Support directory.
        // If not, copy it from the app bundle.
        if fileManager.fileExists(atPath: dependenciesFile.path) == false {
            try copyFile(filename)
        }
        
        // For debug release, enable option to overwrite Dependencies.plist file with new file
        #if DEBUG
        if overwrite == true {
            try fileManager.removeItem(at: dependenciesFile)
            try copyFile(filename)
        }
        #endif   
    }
    
    
    func loadPlatforms() throws -> [DependencyPlatform] {
        let data = try Data(contentsOf: dependenciesFile)
        let decoder = PropertyListDecoder()
        return try decoder.decode([DependencyPlatform].self, from: data)
    }
    
    
    func load(_ platform: Platform? = nil) throws -> DependencyPlatform? {
        let platforms = try loadPlatforms()
        return platforms.filter{ (item) -> Bool in return item.platform == platform }.first
    }
    
    
    /// Called by init when the application support directory is not found
    /// setupNewInstall will create a new app support directory and copy all relevant files
    /// - Throws:   forwards FileManager error or FileNotFound if the Dependencies.plist file
    ///             wasn't found in the bundle
    private func setupNewInstall() throws {
        try fileManager.createDirectory(at: folder, withIntermediateDirectories: true, attributes: nil)
    }
    
    
    /// Copies file from bundle to application support directory
    ///
    /// - Parameter filename: filename, e.g. "ethereum.plist"
    /// - Throws:   fileNotFound in case file doesn't exist in the bundle.
    ///             Forwards FileManager error in all other cases
    private func copyFile(_ filename: String) throws {
        guard let source = Bundle.main.url(forResource: filename, withExtension: nil) else {
            assertionFailure() // Source file does not exist in bundle
            throw EditorError.fileNotFound(filename)
        }
        try fileManager.copyItem(at: source, to: folder.appendingPathComponent(filename))
    }
}
