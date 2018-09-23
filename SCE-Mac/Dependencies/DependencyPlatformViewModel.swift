//
//  DependencyPlatformViewModel.swift
//  SCE
//
//  Created by Ronald "Danger" Mannak on 9/21/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation

class DependencyPlatformViewModel: DependencyViewModelProtocol {
    
    private let platform: DependencyPlatform
    
    /// Name of the platform
    let name: String
    
    var displayName: String { return name }
    
//    private (set) var isSelected: Bool = true // TODO: select yet if
    
    let frameworks: [DependencyFrameworkViewModel]
    
    var children: [DependencyViewModelProtocol]? { return frameworks }

    let path: String? = nil
    
    private (set) var version: String? = nil
    
    private (set) var minimumVersion: String?
    
    private (set) var required: Bool = false
    
    func updateVersion(completion: @escaping (String) -> ()) throws { }
    
    var state: DependencyState {
        
        // If platform is an empty placeholder
        if frameworks.isEmpty { return .comingSoon }
        
        // Platform installing
        if frameworks.filter({ $0.state == .installing }).isEmpty == false {
            return .installing
        }
        
        // All required dependencies are up to date
        if frameworks.filter({ $0.state == .uptodate && $0.required == true }).count == frameworks.filter({ $0.required == true }).count {
            return .uptodate
        }
        
        //            print(frameworks.filter({ $0.state == .notInstalled && $0.required == true }))
        // Not all required dependencies are installed
        if frameworks.filter({ $0.state == .notInstalled && $0.required == true }).isEmpty == false {
            return .notInstalled
        }
        
        // Not all required dependencies are up to date
        if frameworks.filter({ $0.state == .outdated && $0.required == true }).isEmpty == false {
            return .outdated
        }
        
        return .unknown
    }
    
    
    init(_ platform: DependencyPlatform) {
        self.platform = platform
        frameworks = platform.frameworks.map{ DependencyFrameworkViewModel($0) }
        name = platform.name
        
    }
    
    func install(output: @escaping (String) -> Void, finished: @escaping () -> Void) throws -> [ScriptTask]? {
        
        return try platform.install(output: output, finished: finished)
    }
    
    func update(output: @escaping (String) -> Void, finished: @escaping () -> Void) throws -> [ScriptTask]? {
        
        return try platform.update(output: output, finished: finished)
    }
}
