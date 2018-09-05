//
//  EthereumFileSetup.swift
//  SCE-Mac
//
//  Created by Ronald "Danger" Mannak on 9/5/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation

struct EthereumFileSetup: FileSetupProtocol {
    
    private let folder: URL!
    private let manager = FileManager.default
    
    func needsSetupUI() -> Bool {
        return true
    }
    
    init() throws {
        guard let support = manager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            throw EditorError.directoryNotFound("Application Support")
        }
        folder = support.appendingPathComponent("com.composite.composite")
        var isDirectory = ObjCBool(booleanLiteral: false)
        let appDirectoryExists = manager.fileExists(atPath: folder.path, isDirectory: &isDirectory)
        if appDirectoryExists == true && isDirectory.boolValue == false {
            try manager.removeItem(at: folder)
            try setupNewInstall()
        } else if appDirectoryExists == false {
            try setupNewInstall()
        }
    }
    
    
    /// Called by init when
    ///
    private func setupNewInstall() throws {
        try manager.createDirectory(at: folder, withIntermediateDirectories: true, attributes: nil)
    }
    
}
