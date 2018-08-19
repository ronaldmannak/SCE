//
//  FileBrowser.swift
//  SCE-Mac
//
//  Created by Ronald "Danger" Mannak on 8/18/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Cocoa

class FileBrowser: NSObject {
    let name: String
    var children = [FileItem]()
    
    init(name: String) {
        self.name = name
    }
    

}
