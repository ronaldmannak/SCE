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
    let installed: Bool
    let dependencies: [Dependency]
    
    func viewModel() -> DependencyViewModel {
        return DependencyViewModel(self)
    }
}

