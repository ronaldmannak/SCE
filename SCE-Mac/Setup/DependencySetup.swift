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
//    private let folder: URL!
    private let dependenciesFile: URL!
    private let fileManager = FileManager.default    
    
    /// Sets folder and file variables.
    ///
    /// - Throws:   Forwards FileManager error if Application Support directory is not found
    init()  {
        dependenciesFile = Bundle.main.url(forResource: filename, withExtension: nil)
    }
    
    /// Loads all depencies for all platforms from Dependencies.plist
    ///
    /// - Returns:  Array of DependencyPlatforms
    /// - Throws:   Codable error
    func loadPlatforms() throws -> [DependencyPlatform] {
        let data = try Data(contentsOf: dependenciesFile)
        let decoder = PropertyListDecoder()
        return try decoder.decode([DependencyPlatform].self, from: data)
    }
    
    
    /// Loads all dependenies for a single platform
    ///
    /// - Parameter platform: the platform, e.g. .ethereum
    /// - Returns:  The DependencyPlatform or nil
    /// - Throws:   Codable error
    func load(_ platform: Platform? = nil) throws -> DependencyPlatform? {
        let platforms = try loadPlatforms()
        return platforms.filter{ (item) -> Bool in return item.platform == platform }.first
    }
    
    func loadViewModels() throws -> [DependencyPlatformViewModel] {
        return try loadPlatforms().map { DependencyPlatformViewModel($0) }
    }
    
}
