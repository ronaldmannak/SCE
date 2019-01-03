//
//  BuildTool.swift
//  SCE
//
//  Created by Ronald "Danger" Mannak on 9/30/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation

struct BuildTool {
    /// E.g. usr/bin/etherlime
    let buildTool: URL
    
    /// E.g compile $(PROJECTNAME)
    let arguments: String
    
    let workdirectory: URL
}
