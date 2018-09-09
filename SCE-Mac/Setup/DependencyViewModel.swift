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
        case unknown, uptodate, outdated, notInstalled
    }
    
    let dependency: Dependency?
    
    let name: String
    let path: String
    private let isInstalled: Bool
    let required: Bool
    
    var state: State {        
        if isInstalled == false {
            return .notInstalled
        }
        // TODO: check version
        return .outdated
//        return .unknown
    }
    var version: String? = nil
    
    var children: [DependencyViewModel]
    
    init(_ dependency: Dependency) {
        
        self.dependency = dependency
        name = dependency.name.replacingOccurrences(of: ".app", with: "").capitalizedFirstChar()
        path = dependency.url.path
        isInstalled = dependency.isInstalled
        required = dependency.required
        
        children = [DependencyViewModel]()
    }
    
    init(_ platform: DependencyPlatform) {
        
        dependency = nil
        name = platform.platform.description
        path = ""
        children = platform.dependencies.map{ DependencyViewModel($0) }
        required = false
    
        isInstalled = (children.filter{ $0.isInstalled == false && $0.required == true }.isEmpty)
    }
    
    func fetchVersion(completion: @escaping (String) -> ()) throws {
        
        guard isInstalled == true else { return }
        
        try dependency?.fileVersion {
            self.version = $0
            completion($0)
        }
    }
}
