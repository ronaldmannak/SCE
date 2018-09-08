//
//  BlockchainSelectViewController.swift
//  SCE-Mac
//
//  Created by Ronald "Danger" Mannak on 9/7/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Cocoa

class InstallBlockchainViewController: NSViewController {
    
    weak var container: InstallContainerViewController!
    @IBOutlet weak var outlineView: NSOutlineView!
    @IBOutlet var console: NSTextView!
    
    var platforms = [DependencyPlatform]() {
        didSet {
            outlineView.reloadData()
        }
    }
    
    var dependencies: DependencySetup! {
        didSet {
            do {
                platforms = try dependencies.loadPlatforms()
            } catch {
                let alert = NSAlert(error: error)
                alert.runModal()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func install(_ sender: Any) {
        container.showComplete()
    }
    
    @IBAction func cancel(_ sender: Any) {
        // Stop NSTask
        view.window?.close()
    }
}

extension InstallBlockchainViewController: NSOutlineViewDelegate {
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        
        let title: String
        let image: NSImage?
        if let platform = item as? DependencyPlatform {
            title = platform.platform.description
            image = nil
        } else if let dependency = item as? Dependency {
            title = dependency.url.path
            image = nil
            
            // condition nstablecolumn (button cell)
        } else {
            assertionFailure()
            return nil
        }
        guard let view: NSTableCellView = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "NameCell"), owner: self) as? NSTableCellView else {
            return nil
        }
        view.textField?.stringValue = title
        view.imageView?.image = image
        return view
    }

    func outlineViewSelectionDidChange(_ notification: Notification) {
//        guard let outlineView = notification.object as? NSOutlineView else { return }
//
//        let supportedPathExtensions = ["sol"]
//        let selectedIndex = outlineView.selectedRow
//        guard let item = outlineView.item(atRow: selectedIndex) as? FileItem, supportedPathExtensions.contains(item.url.pathExtension) else { return }
//
//        let editWindowController = (view.window?.windowController as! EditWindowController)
//        editWindowController.setEditor(url: item.url)
    }
}

extension InstallBlockchainViewController: NSOutlineViewDataSource {
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let item = item as? DependencyPlatform {
            return item.dependencies.count
        } else {
            // item is nil, root
            return platforms.count
        }
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let _ = item as? DependencyPlatform { return true }
        return false
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        
        if let item = item as? DependencyPlatform {
            return item.dependencies[index]
        } else if item == nil {
            // Root
            return platforms[index]
        } else {
            assertionFailure()
            return ""
        }
    }
}
