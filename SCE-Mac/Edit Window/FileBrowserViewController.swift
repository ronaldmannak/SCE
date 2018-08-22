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
    
    private var root: FileItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    /// Called from EditWindowController
    func load(url: URL, projectName: String) throws {
        root = try FileItem(url: url, projectName: projectName)
        fileView.reloadData()
    }
}

extension FileBrowserViewController: NSOutlineViewDelegate {
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let item = item as? FileItem else { return nil }
        guard let view: NSTableCellView = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "FileCell"), owner: self) as? NSTableCellView else {
            return nil
        }
        view.textField?.stringValue = item.localizedName
        view.imageView?.image = item.icon
        print(item.icon)
        
        return view
    }
}

extension FileBrowserViewController: NSOutlineViewDataSource {
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        
        // If root is not set, don't show anything
        guard root != nil else { return 0 }
        
        // item is nil if requesting root
        guard let item = item as? FileItem else { return 1 }
        
        return item.children.count
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        guard let item = item as? FileItem else {
            assertionFailure()
            return false
        }
        return item.isDirectory
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        guard let item = item as? FileItem else {
            return root!
        }
        return item.children[index]
    }
}
