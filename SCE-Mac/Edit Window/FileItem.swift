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
    
    let name: String
    let localizedName: String?
    let icon: NSImage?
    let isDirectory: Bool

    init(url: URL) throws {
        self.url = url
        let fileResource = try url.resourceValues(forKeys: [URLResourceKey.nameKey])
        name = fileResource.name ?? "<unknown>"
        localizedName = fileResource.localizedName
        icon = fileResource.customIcon
        isDirectory = fileResource.isDirectory ?? false
    }
}
