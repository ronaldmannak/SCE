//
//  DependencyViewModel.swift
//  SCE
//
//  Created by Ronald "Danger" Mannak on 9/21/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation
import Cocoa

class DependencyViewModel {
    
    private let dependency: Dependency
    
    let name: String
    
    var displayName: String { return state.display(name: name)}
    
    let path: String?
    
    var version: String? { return dependency.versionNumber }
    
    private (set) var isFrameworkVersion: Bool
    
    private (set) var minimumVersion: String?
        
    let required: Bool
    
//    var image: NSImage {
//        
//        let image: NSImage
//        
//        switch state {
//        case .unknown: image = NSImage()
//        case .uptodate: image = NSImage()
//        case .outdated: image = NSImage()
//        case .notInstalled: image = NSImage()
//        case .installing, .comingSoon: image = NSImage()
//        }
//        return image
//    }
    
    var state: DependencyState {
        
        // Installing
        if dependency.isInstalling() {
            return .installing
        }
        
        // Not installed
        if dependency.isInstalled == false {
            return .notInstalled
        }
        
        // upToDate / isOutdated
        if let minimumVersion = minimumVersion, let version = version, version >= minimumVersion {
            return .uptodate
        } else if let minimumVersion = minimumVersion, let version = version, version < minimumVersion {
            return .uptodate
//            return .outdated
            // TODO: there seems to be a bug in the version comparison. 0.10.1 < 0.9.5 = true
        }
        
        return .unknown
    }
    
    init(_ dependency: Dependency) {
        
        self.dependency = dependency
        name = dependency.description
        path = dependency.url.path
        required = dependency.required
        minimumVersion = dependency.minimumVersion
        isFrameworkVersion = dependency.isFrameworkVersion
    }

    func versionQueryOperation() -> BashOperation? {
        return dependency.versionQueryOperation()
    }
    
    func versionQueryParser(_ output: String) -> String {
        return dependency.versionQueryParser(output)
    }
    
    func install() throws -> [BashOperation]? {
        let operation = try dependency.install()
        return operation != nil ? [operation!] : nil
    }
    
    func update() throws -> [BashOperation]? {
        let operation = try dependency.update()
        return operation != nil ? [operation!] : nil
    }
}
