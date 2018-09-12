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
        guard let delegate = NSApplication.shared.delegate as? AppDelegate else { return }
        delegate.showChooseTemplate(self)
    }
    
    @IBAction func button1(_ sender: Any) {
        
        // NSButton is a subclass of NSView
        guard let sender = sender as? NSView else { return }
        let row = outlineView.row(for: sender)
        guard let item = outlineView.item(atRow: row) as? DependencyViewModel else { return }
        
        switch item.state {

        case .notInstalled, .outdated:
            
            let isPlatform = item.dependency == nil
            if isPlatform {
                for child in item.children {
                    addTask(item: child)
                }
            } else {
                addTask(item: item)
            }
        default:
            // This should not happen
            return
        }
    }
    
    @IBAction func button2(_ sender: Any) {
        let openPanel = NSOpenPanel()
        openPanel.beginSheetModal(for: self.view.window!) { (response) in
            // TODO
        }
    }
}

// Queue functions
extension InstallBlockchainViewController {
    
    
    /// Add task to ScriptTask queue
    ///
    /// - Parameter item: <#item description#>
    func addTask(item: DependencyViewModel) {
        
        let showOutputInConsole: (String) -> Void = { output in
            print(output)
            let previousOutput = self.console.string
            let nextOutput = previousOutput + "\n" + output
            self.console.string = nextOutput
            let range = NSRange(location:nextOutput.count,length:0)
            self.console.scrollRangeToVisible(range)
        }
        
        let finish: () -> Void = {
            item.isInstalling = false
            self.outlineView.reloadItem(item)
//            self.outlineView.reloadData()
//            do {
//                self.platforms = try self.dependencies.loadViewModels()
//            } catch {
//                let alert = NSAlert(error: error)
//                alert.runModal()
//            }
        }
        
        do {
            let task: ScriptTask?
            switch item.state {
            case .outdated:
                
                item.isInstalling = true
                task = try item.dependency?.update(output: { (output) in
                    showOutputInConsole(output)
                }, finished: finish)
                
            case .notInstalled:
                
                item.isInstalling = true
                task = try item.dependency?.install(output: showOutputInConsole, finished: finish)
                
            default:
                return
            }
            task?.run()
        } catch {
            let alert = NSAlert(error: error)
            alert.runModal()
        }
        // Reload in case installing icon must be shown
        outlineView.reloadItem(item)
//        self.outlineView.reloadData()
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
            
            let image: NSImage
            let emoji: String
            switch item.state {
            case .unknown:
                image = NSImage() // Question mark
                emoji = "❓"
            case .uptodate:
                image = NSImage() // Green
                emoji = "✅"
            case .outdated:
                image = NSImage() // Orange warning
                emoji = "⚠️"
            case .notInstalled:
                image = NSImage() // Red cross
                emoji = "❌"
            case .installing:
                image = NSImage()
                emoji = "🕗"
            }
            view.imageView?.image = image

            view.textField?.stringValue = emoji + " " + item.name
            
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
            
            view.imageView?.image = nil
            if item.state == .notInstalled && !item.path.isEmpty || item.state == .installing {
                // Show not installed if item isn't installed and isn't a platform
                view.textField?.stringValue = "" //(Not installed)"
//                view.textField?.textColor = .red
            } else {
                view.textField?.stringValue = item.path
//                view.textField?.textColor = .black
            }
        
        case "ActionColumn":
            
            // If item is an empty platform, show "coming soon" label
            let isEmptyPlatform = item.dependency == nil && item.children.isEmpty
            guard !isEmptyPlatform else  {
                view.imageView?.image = nil
                view.textField?.stringValue = "Coming soon"
                return view
            }
            
            // Fetch the view with two buttons
            guard let buttonView: NSTableCellView = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ActionCell"), owner: self) as? NSTableCellView else {
                return nil
            }
            
            let button1: NSButton = buttonView.subviews.filter { $0.identifier!.rawValue == "Button1" }.first! as! NSButton
            let button2: NSButton = buttonView.subviews.filter { $0.identifier!.rawValue == "Button2" }.first! as! NSButton
            
            switch item.state {
            case .unknown, .notInstalled:
                
                button1.isHidden = false
                button2.isHidden = false
                button1.isEnabled = true
                
                button1.title = "Install \(item.name)"
                button2.title = "Locate"
                
                // Hide Locate button if item is platform
                if item.dependency == nil {
                    button2.isHidden = true
                }

            case .uptodate:
                
                button1.isHidden = true
                button2.isHidden = true
                button1.isEnabled = true
                
            case .outdated:
                
                button1.isHidden = false
                button2.isHidden = true
                button1.isEnabled = true
                
                button1.title = "Update \(item.name)"
                
            case .installing:

                button1.isHidden = false
                button2.isHidden = true
                button1.isEnabled = false
                
                button1.title = "Installing..."
            }

            return buttonView
            
        default:
            
            print("Unknown column id: \(identifier)")
            assertionFailure()
        }
        return view
        
    }

    func selectionShouldChange(in outlineView: NSOutlineView) -> Bool {
        return false
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
