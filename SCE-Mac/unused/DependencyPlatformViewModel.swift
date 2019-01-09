//
//  DependencyPlatformViewModel.swift
//  SCE
//
//  Created by Ronald "Danger" Mannak on 9/21/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation

class DependencyPlatformViewModel: DependencyViewModelProtocol {
    
    let platformDependency: DependencyPlatform
    
    /// Name of the platform
    let name: String
    
    var displayName: String { return name }
    
    let frameworks: [DependencyFrameworkViewModel]
    
    var children: [DependencyViewModelProtocol]? { return frameworks }

    let path: String? = nil
    
    private (set) var version: String? = nil
    
    private (set) var required: Bool = false
    
    func versionQueryOperation() -> BashOperation? {
        return nil
    }
    
    func versionQueryParser(_ output: String) -> String {
        return ""
    }
    
    var state: DependencyState {
        
        // If platform is an empty placeholder
        if frameworks.isEmpty { return .comingSoon }
        
        // Platform installing
        if frameworks.filter({ $0.state == .installing }).isEmpty == false {
            return .installing
        }
        
        if frameworks.filter({ $0.state == .notInstalled}).isEmpty == false {
            return .notInstalled
        }
        
        // Not all required dependencies are up to date
        if frameworks.filter({ $0.state == .outdated && $0.required == true }).isEmpty == false {
            return .outdated
        }
        
        // All required dependencies are up to date
        if frameworks.filter({ $0.state == .uptodate && $0.required == true }).count == frameworks.filter({ $0.required == true }).count {
            return .uptodate
        }
        
        return .unknown
    }
    
    
    init(_ platform: DependencyPlatform) {
        self.platformDependency = platform
        frameworks = platform.frameworks.map{ DependencyFrameworkViewModel($0) }
        name = platform.name
        
    }
    
    func install() throws -> [BashOperation]? {
        
        return try platformDependency.install()
    }
    
    func update() throws -> [BashOperation]? {
        
        return try platformDependency.update()
    }
}
