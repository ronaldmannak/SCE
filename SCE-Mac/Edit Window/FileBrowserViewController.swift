//
//  FileBrowserViewController.swift
//  SCE-Mac
//
//  Created by Ronald "Danger" Mannak on 8/18/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Cocoa

class FileBrowserViewController: NSViewController {
    
    @IBOutlet weak var fileView: NSOutlineView!
    
    var url: URL! {
        didSet {
//            fileView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}

extension FileBrowserViewController: NSOutlineViewDelegate {
    
}

//extension FileBrowserViewController: NSOutlineViewDataSource {
//    
//    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
//        <#code#>
//    }
//    
//    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
//        <#code#>
//    }
//    
//    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
//        <#code#>
//    }
//    
//    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
//        <#code#>
//    }
//}
