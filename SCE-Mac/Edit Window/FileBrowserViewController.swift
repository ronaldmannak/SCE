//
//  FileBrowserViewController.swift
//  SCE-Mac
//
//  Created by Ronald "Danger" Mannak on 8/18/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Cocoa

/// TODO: key bindings https://www.raywenderlich.com/1201-nsoutlineview-on-macos-tutorial
class FileBrowserViewController: NSViewController {
    
    @IBOutlet weak var fileView: NSOutlineView!
    private var root: FileItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func fileViewDoubleClick(_ sender: NSOutlineView) {
        guard let item = sender.item(atRow: sender.clickedRow) as? FileItem, item.isDirectory == true else { return }
        
        if sender.isItemExpanded(item) {
            sender.collapseItem(item)
        } else {
            sender.expandItem(item)
        }
    }
    
    /// Called from EditWindowController
    func load(url: URL, projectName: String) throws {
        root = try FileItem(url: url, projectName: projectName)
        fileView.reloadData()
        fileView.expandItem(root)
        fileView.expandItem(root!.children[3]) // TODO: fix. Hardcoding expand contracts directory
//        let selectFileItem = root!.children[3].children[0]
//        let index = fileView.childIndex(forItem: selectFileItem)
//        print(index)
        fileView.selectRowIndexes([5], byExtendingSelection: false)
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
        return view
    }
    
    func outlineViewSelectionDidChange(_ notification: Notification) {
        guard let outlineView = notification.object as? NSOutlineView else { return }
        
        let supportedPathExtensions = ["sol"]
        let selectedIndex = outlineView.selectedRow
        guard let item = outlineView.item(atRow: selectedIndex) as? FileItem, supportedPathExtensions.contains(item.url.pathExtension) else { return }

        (view.window?.windowController as! EditWindowController).setEditor(url: item.url)
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
