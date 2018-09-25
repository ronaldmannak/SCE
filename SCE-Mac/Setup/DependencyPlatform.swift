//
//  DependencyPlatform.swift
//  SCE-Mac
//
//  Created by Ronald "Danger" Mannak on 9/5/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation

struct DependencyPlatform: Codable {
    
    let platform: Platform
    
    // URL path to more info, usually project site. E.g. https://ethereum.org
    let projectUrl: String
    
    // URL path to documenation, e.g. http://www.ethdocs.org/en/latest/
    let documentationUrl: String
    
    var name: String {
        return platform.description
    }
    
    let frameworks: [DependencyFramework]
    
    func install(output: @escaping (String) -> Void, finished: @escaping () -> Void) throws -> [ScriptTask] {
        
        guard let defaultFramework = frameworks.filter({ $0.defaultFramework == true }).first else {
            return []
        }
        
        return try defaultFramework.install(output: output, finished: finished)
    }
    
    func update(output: @escaping (String) -> Void, finished: @escaping () -> Void) throws -> [ScriptTask] {
  
        return try frameworks.compactMap({ try $0.update(output: output, finished: finished) }).flatMap{ $0 }
    }
}

