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
            
            //            let datasource: NSOutlineViewDataSource = {
            //
            //            }
            
            
            //            if let platform = try setup.load(.ethereum) {
            //                for dependency in platform.dependencies {
            //                    print("\(dependency.description) is installed: \(dependency.isInstalled)")
            //                    try dependency.suggestLocation{ location in
            //                        print("suggested location: \(location)")
            //                    }
            //                    try dependency.fileVersion() { version in
            //                        print("\(dependency.description): \(version)")
            //                    }
            //                }
            //            }
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
        
//        if item == nil { return nil }
        
        print("item: \(item)")
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
            return nil
//            title = ""
//            image = nil
//            fatalError()
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

        print("=====")
        print(item)
        if let item = item {
            return 0
        } else {
            // item is nil, root
            print("number of children: \(platforms.count)")
            return platforms.count
        }
//        // If root is not set, don't show anything
//        guard root != nil else { return 0 }
//
//        // item is nil if requesting root
//        guard let item = item as? FileItem else { return 1 }
//
//        return item.children.count

    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        
        if let item = item as? Platform { return true }
        return false
//        guard let item = item as? FileItem else {
//            assertionFailure()
//            return false
//        }
//        return item.isDirectory
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
