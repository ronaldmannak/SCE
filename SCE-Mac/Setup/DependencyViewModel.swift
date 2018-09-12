//
//  DependencyViewModel.swift
//  SCE-Mac
//
//  Created by Ronald "Danger" Mannak on 9/8/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation

class DependencyViewModel {

    enum State {
        case unknown, uptodate, outdated, notInstalled, installing
    }
    
    let dependency: Dependency?
    
    let name: String
    let path: String
    
    var minimumVersion: String?
    var version: String? = nil
    
    // Temp vars for state
    var isInstalling: Bool = false // this is called by InstallBlockchainViewController. should be fixed
    private let required: Bool
    var state: State {
        
        // TODO: why don't we simply subclass dependencyViewModel into platform and child?
        
        // Handle platforms first
        if self.dependency == nil {
            
            // If platform is an empty placeholder
            if children.isEmpty { return .installing }
            
            // Platform installing
            if children.filter({ $0.state == .installing }).isEmpty == false {
                return .installing
            }
            
            // All required dependencies are up to date
            if children.filter({ $0.state == .uptodate && $0.required == true }).count == children.filter({ $0.required == true }).count {
                return .uptodate
            }
            
            // Not all required dependencies are installed
            if children.filter({ $0.state == .notInstalled && $0.required == true }).isEmpty == false {
                return .notInstalled
            }
            
            // Not all required dependencies are up to date
            if children.filter({ $0.state == .outdated && $0.required == true }).isEmpty == false {
                return .outdated
            }
            
            return .unknown
        }
        
        // Handle dependencies next
        
        // Installing
        if isInstalling == true {
            return .installing            
        }
        
        // Not installed
        if dependency!.isInstalled == false {
            return .notInstalled
        }
        
        // upToDate / isOutdated
        if let minimumVersion = minimumVersion, let version = version, version >= minimumVersion {
            return .uptodate
        } else if let minimumVersion = minimumVersion, let version = version, version < minimumVersion {
            return .outdated
        }
        
        return .unknown
    }
    
    var children: [DependencyViewModel]
    
    init(_ dependency: Dependency) {
        
        self.dependency = dependency
        name = dependency.name.replacingOccurrences(of: ".app", with: "").capitalizedFirstChar()
        path = dependency.url.path
        required = dependency.required
        minimumVersion = dependency.minimumVersion
        
        children = [DependencyViewModel]()
    }
    
    init(_ platform: DependencyPlatform) {
        
        dependency = nil
        name = platform.platform.description
        path = ""
        children = platform.dependencies.map{ DependencyViewModel($0) }
        required = false
    }
    
    func fetchVersion(completion: @escaping (String) -> ()) throws {
        
        guard let dependency = dependency, dependency.isInstalled == true else { return }
        
        try dependency.fileVersion {
            self.version = $0
            completion($0)
        }
    }
}
