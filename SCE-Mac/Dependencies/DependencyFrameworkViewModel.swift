//
//  DependencyFrameworkViewModel.swift
//  SCE
//
//  Created by Ronald "Danger" Mannak on 9/21/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation

class DependencyFrameworkViewModel: DependencyViewModelProtocol {

    private let framework: DependencyFramework
    
    private var task: ScriptTask? = nil
    
    private (set) var name: String
    
    private (set) var path: String?
    
    private (set) var version: String?
    
    private (set) var minimumVersion: String? = nil
    
    private (set) var required: Bool = false
    
    func updateVersion(completion: @escaping (String) -> ()) throws {
        
        guard let mainDependency = dependencies.filter({ $0.isPlatformVersion == true }).first else {
            return
        }
        guard let version = mainDependency.version else {
            try mainDependency.updateVersion {
                self.version = $0
                completion($0)
            }
            return
        }
        self.version = version
        completion(version)
    }
    
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

    func install(output: @escaping (String) -> Void, finished: @escaping () -> Void) throws -> [ScriptTask]? {
        
        return try framework.install(output: output, finished: finished)
    }
    
    func update(output: @escaping (String) -> Void, finished: @escaping () -> Void) throws -> [ScriptTask]? {
        
        return try framework.update(output: output, finished: finished)
    }
    
//    func install() {
//
//        // if brew is not installed, just show the "install brew" alert
//        if let brew = dependencies.first, brew.name == "Brew", brew.state == .notInstalled {
//            addTask(item: brew)
//            return
//        }
//
//        for component in dependencies {
//            addTask(item: component)
//        }
//    }
//


    
    
}
