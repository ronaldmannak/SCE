//
//  CopyFile.swift
//  SCE
//
//  Created by Ronald "Danger" Mannak on 1/4/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Foundation


struct CopyFile: Codable {
    let filename: String
    let destination: String
    let renameFileToProjectName: Bool
    
    func copyfile(projectName: String? = nil) {
        // ...
    }
}

