//
//  FileItem.swift
//  SCE-Mac
//
//  Created by Ronald "Danger" Mannak on 8/18/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Cocoa

class FileItem: NSObject {
    let url: URL
    let projectName: String?
    
    let localizedName: String
    let icon: NSImage?
    let isDirectory: Bool

    init(url: URL, projectName: String? = nil) throws {
        
        let filemanager = FileManager.default
        var isDirectory: ObjCBool = false
        guard filemanager.fileExists(atPath: url.path, isDirectory: &isDirectory) else {
            throw EditorError.fileNotFound(url.path)
        }
        
        self.url = url
        self.projectName = projectName
        
        let fileResource = try url.resourceValues(forKeys: [URLResourceKey.nameKey])
        localizedName = fileResource.localizedName ?? fileResource.name ?? projectName ?? "<UNKNOWN>"
        icon = fileResource.customIcon
        self.isDirectory = isDirectory.boolValue
    }
    
    lazy var children: [FileItem] = {
        
        let fileManager = FileManager.default
        guard isDirectory == true, fileManager.fileExists(atPath: url.path), let files = try? fileManager.contentsOfDirectory(atPath: url.path) else { return [FileItem]() }
        
        var _children = [FileItem]()
        for file in files {
            if let item = try? FileItem(url: url.appendingPathComponent(file)) {
                _children.append(item)
            }
        }
        return _children
    }()

}
