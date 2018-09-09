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
    
    var platforms = [DependencyViewModel]() {
        didSet {
            outlineView.reloadData()
        }
    }
    
    var dependencies: DependencySetup! {
        didSet {
            do {
                platforms = try dependencies.loadViewModels()
            } catch {
                let alert = NSAlert(error: error)
                alert.runModal()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func done(_ sender: Any) {
        container.showComplete()
    }
    
    @IBAction func cancel(_ sender: Any) {
        // Stop NSTask
        view.window?.close()
    }
}

extension InstallBlockchainViewController: NSOutlineViewDelegate {
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        
        guard let identifier = tableColumn?.identifier.rawValue else { return nil }
        
        guard let view: NSTableCellView = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "NameCell"), owner: self) as? NSTableCellView else {
            return nil
        }
        
        guard let item = item as? DependencyViewModel else { return nil }
        
        switch identifier {
        case "DependencyColumn":
            
            view.textField?.stringValue = item.name
            
            let image: NSImage
            switch item.state {
            case .unknown:
                image = NSImage() // Question mark
            case .uptodate:
                image = NSImage() // Green
            case .outdated:
                image = NSImage() // Orange warning
            case .notInstalled:
                image = NSImage() // Red cross
            }
            
        case "VersionColumn":
            
            view.textField?.stringValue = ""
            if let version = item.version {
                view.textField?.stringValue = version
            } else {
                do {
                    try item.fetchVersion { _ in outlineView.reloadData() }
                } catch {
                    print(error)
                    assertionFailure()
                }
            }
            
        case "PathColumn":
            
            view.textField?.stringValue = item.path
            view.imageView?.image = nil
        
        case "ActionColumn":
            
            view.imageView?.image = nil
            print(item.name)
            // If empty platform,
            if item.dependency == nil && item.children.isEmpty {
                view.textField?.stringValue = "Coming soon"
            } else {
                switch item.state {
                case .unknown:
                    view.textField?.stringValue = "Install \(item.name)"
                case .uptodate:
                    view.textField?.stringValue = ""
                case .outdated:
                    view.textField?.stringValue = "Update \(item.name)"
                case .notInstalled:
                    view.textField?.stringValue = "Install \(item.name)"
                }
            }
            
        default:
            
            print("Unknown column id: \(identifier)")
            assertionFailure()
        }
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
        
        if item == nil {
            // Root
            return platforms.count
        }
        
        return (item as? DependencyViewModel)?.children.count ?? 0
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        
        guard let item = item as? DependencyViewModel else { return false }
        
        return !item.children.isEmpty
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        
        if item == nil {
            // Root
            return platforms[index]
        }
        
        guard let item = item as? DependencyViewModel else { return "" }
        
        return item.children[index]
    }
}
