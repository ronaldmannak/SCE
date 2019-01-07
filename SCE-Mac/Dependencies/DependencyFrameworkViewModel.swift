//
//  DependencyFrameworkViewModel.swift
//  SCE
//
//  Created by Ronald "Danger" Mannak on 9/21/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation

class DependencyFrameworkViewModel: DependencyViewModelProtocol {

    let framework: DependencyFramework
    
    private (set) var name: String
    
    private (set) var path: String?
    
    private (set) var version: String?
    
    private (set) var minimumVersion: String? = nil
    
    private (set) var required: Bool = false
    
    var displayName: String { return state.display(name: framework.name) }
    
    var isDefaultFramework: Bool {
        return framework.defaultFramework
    }
    
    let dependencies: [DependencyViewModel]
    
    var children: [DependencyViewModelProtocol]? { return dependencies }
    
    var state: DependencyState {
        
        if dependencies.isEmpty { return .unknown }
        
        // Platform installing
        if dependencies.filter({ $0.state == .installing }).isEmpty == false {
            return .installing
        }
        
        // All required dependencies are up to date
        if dependencies.filter({ $0.state == .uptodate && $0.required == true }).count == dependencies.filter({ $0.required == true }).count {
            return .uptodate
        }
        
        //            print(frameworks.filter({ $0.state == .notInstalled && $0.required == true }))
        // Not all required dependencies are installed
        if dependencies.filter({ $0.state == .notInstalled && $0.required == true }).isEmpty == false {
            return .notInstalled
        }
        
        // Not all required dependencies are up to date
        if dependencies.filter({ $0.state == .outdated && $0.required == true }).isEmpty == false {
            return .outdated
        }
        
        return .unknown
    }
    
    init(_ framework: DependencyFramework) {
        self.framework = framework
        name = framework.name
        dependencies = framework.dependencies.map { DependencyViewModel($0) }
    }

    func install() throws -> [BashOperation]? {
        
        return try framework.install()
    }
    
    func update() throws -> [BashOperation]? {
        
        return try framework.update()
    }
    
    func versionQueryOperation() -> BashOperation? {
        return nil
    }
    
    func versionQueryParser(_ output: String) -> String {
        return ""
    }
//    func updateVersion(completion: @escaping (String) -> ()) throws {
//
//        guard let mainDependency = dependencies.filter({ $0.isPlatformVersion == true }).first else {
//            return
//        }
//        guard let version = mainDependency.version else {
//            try mainDependency.updateVersion {
//                self.version = $0
//                completion($0)
//            }
//            return
//        }
//        self.version = version
//        completion(version)
//    }

}
