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
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    var platforms = [DependencyViewModelProtocol]() {
        didSet {
            outlineView.reloadData()
        }
    }
    
    var dependencies: DependencySetup! {
        didSet {
            do {
                platforms = try dependencies.loadViewModels()
                for platform in platforms {
//                    print("fetching version for \(platform.name)")
                    
                    guard let frameworks = platform.children else { continue }
                    for framework in frameworks {
                        
                        guard let tools = framework.children else { continue }
                        for tool in tools {
                            
                            try tool.updateVersion{ _ in
                                self.outlineView.reloadItem(platform)
                                self.outlineView.reloadItem(framework)
                                self.outlineView.reloadItem(tool)
                            }
                        }
//
//                        print("fetching version for \(tool.name)")
//                        try tool.updateVersion{ _ in
////                            self.outlineView.reloadItem(tool)
//                            self.outlineView.reloadItem(platform)
//                        }
                    }
                }
                outlineView.expandItem(nil, expandChildren: true)
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
//        guard let sender = sender as? NSView else { return }
//        let row = outlineView.row(for: sender)
//
//        guard let item = outlineView.item(atRow: row) as? DependencyViewModelProtocol else { return }
//
//        do {
//            let tasks: ScriptTask
//            switch item.state {
//            case .notInstalled:
//                tasks = item.install(output: { output in
//                    <#code#>
//                }, finished: {
//                    <#code#>
//                })
//            default:
//                tasks = item.update(output: { output in
//                    <#code#>
//                }, finished: {
//                    <#code#>
//                })
//            }
//
//        } catch {
//            let alert = NSAlert(error: error)
//            alert.runModal()
//            updateProgressIndicator()
//        }
        
//
//
//            // if brew is not installed, just show the "install brew" alert
//            if let brew = item.dependencies.first, brew.name == "Brew", brew.state == .notInstalled {
//                addTask(item: brew)
//                return
//            }
//
//            for component in item.dependencies {
//                addTask(item: component)
//            }
//
//        } else if let item = outlineView.item(atRow: row) as? DependencyPlatformViewModel {
//
//
//            // If platform, update all components
//            // Unless brew is not installed, then just show the "install brew" alert
//            if let brew = item.frameworks.first, brew.name == "Brew", brew.state == .notInstalled {
//                addTask(item: brew)
//                return
//            }
//
//            for component in item.children {
//                addTask(item: component)
//            }
//
//        }
//
//
//
//            DependencyViewModelProtocol
//
//
//
//            else { return }
//
//        if item.dependency == nil {
//            // If platform, update all components
//
//            // Unless brew is not installed, then just show the "install brew alert
//            if let brew = item.children.first, brew.name == "Brew", brew.state == .notInstalled {
//                addTask(item: brew)
//                return
//            }
//
//            for component in item.children {
//                addTask(item: component)
//            }
//            return
//        }
//
//        switch item.state {
//
//        case .notInstalled, .outdated:
//
//            let isPlatform = item.dependency == nil
//            if isPlatform {
//                for child in item.children {
//                    addTask(item: child)
//                }
//            } else {
//                addTask(item: item)
//            }
//        default:
//            // This happens in edge case demo where Ganache is renamed while
//            // running the app.
//            try? item.fetchVersion { _ in self.outlineView.reloadData() }
//            return
//        }
    }
    
//    @IBAction func button2(_ sender: Any) {
//        let openPanel = NSOpenPanel()
//        openPanel.beginSheetModal(for: self.view.window!) { (response) in
//            // TODO
//        }
//    }
}

// Queue functions
extension InstallBlockchainViewController {
    
    
    /// Add task to ScriptTask queue
    ///
    /// - Parameter item: <#item description#>
//    func addTask(item: DependencyViewModelProtocol) {
//        
//        let showOutputInConsole: (String) -> Void = { output in
//
//            let previousOutput = self.console.string
//            let nextOutput = previousOutput + "\n" + output
//            self.console.string = nextOutput
//            let range = NSRange(location:nextOutput.count,length:0)
//            self.console.scrollRangeToVisible(range)
//        }
//        
//        let finish: () -> Void = {
//            
//            do {
//                try item.fetchVersion { _ in
//                    self.outlineView.reloadData()
//                    self.updateProgressIndicator()
//                }
//            } catch {
//                self.outlineView.reloadData()
//                self.updateProgressIndicator()
//            }
//        }
//        
//        do {
//            let task: ScriptTask?
//            switch item.state {
//            case .outdated, .uptodate:
//                
//                // up to date means component has equal or higher version than
//                // listed in the plist file. There could be a newer version available
//                
//                task = try item.dependency?.update(output: { (output) in
//                    showOutputInConsole(output)
//                }, finished: finish)
//                
//            case .notInstalled:
//                
//                task = try item.dependency?.install(output: showOutputInConsole, finished: finish)
//                
//            default:
//                
//                return
//            }
//            
//            task?.run()
//            
//        } catch {
//            
//            let alert = NSAlert(error: error)
//            alert.runModal()
//            updateProgressIndicator()
//        }
//        // Reload in case installing icon must be shown
//        outlineView.reloadItem(item)
//        updateProgressIndicator()
//    }
    
    func updateProgressIndicator() {

        let isUpdating = !platforms.filter { $0.state == .installing }.isEmpty
        
        if isUpdating == true {
            progressIndicator.startAnimation(self)
            progressIndicator.isHidden = false
        } else {
            progressIndicator.stopAnimation(self)
            progressIndicator.isHidden = true
        }        
    }
}

extension InstallBlockchainViewController: NSOutlineViewDelegate {
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        
        guard let identifier = tableColumn?.identifier.rawValue else { return nil }
        
        guard let view: NSTableCellView = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "NameCell"), owner: self) as? NSTableCellView else {
            return nil
        }
        
        if let item = item as? DependencyPlatformViewModel {
            
            switch identifier {
            case "DependencyColumn":
                
                view.imageView?.image = nil
                view.textField?.stringValue = item.displayName
                
            case "VersionColumn", "PathColumn":
                
                view.imageView?.image = nil
                view.textField?.stringValue = ""
                
            case "ActionColumn":
                
                // If item is an empty platform, show "coming soon" label
                guard item.frameworks.isEmpty else {
                    view.imageView?.image = nil
                    view.textField?.stringValue = "Coming soon"
                    return view
                }
                
                // Fetch the view with two buttons
                guard let buttonView: NSTableCellView = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ActionCell"), owner: self) as? NSTableCellView else {
                    return nil
                }
                
                let button1: NSButton = buttonView.subviews.filter { $0.identifier!.rawValue == "Button1" }.first! as! NSButton
                
                switch item.state {
                    
                case .unknown, .notInstalled:
                    
                    button1.isHidden = false
                    button1.isEnabled = true
                    button1.title = "Install toolchain"
                    
                case .uptodate, .outdated:
                    
                    button1.isHidden = true
                    button1.isEnabled = true
                    button1.title = "Update toolchain"
                    
                case .installing:
                    
                    button1.isHidden = false
                    button1.isEnabled = false
                    button1.title = "Installing..."
                    
                case .comingSoon:
                    
                    button1.isHidden = true
                    button1.isEnabled = true
                    
                }
                return buttonView
                
            default:
                
                print("Unknown column id: \(identifier)")
                assertionFailure()
            }
            
        } else if let item = item as? DependencyFrameworkViewModel {
            
            switch identifier {
            case "DependencyColumn":
                
                view.imageView?.image = nil
                view.textField?.stringValue = item.displayName
                
            case "VersionColumn":
                
                view.textField?.stringValue = item.version ?? ""
                
            case "PathColumn":
                
                view.textField?.stringValue = item.path ?? ""
                
            case "ActionColumn":
                
                // Fetch the view with two buttons
                guard let buttonView: NSTableCellView = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ActionCell"), owner: self) as? NSTableCellView else {
                    return nil
                }
                
                let button1: NSButton = buttonView.subviews.filter { $0.identifier!.rawValue == "Button1" }.first! as! NSButton
                
                switch item.state {
                    
                case .unknown, .notInstalled:
                    
                    button1.isHidden = false
                    button1.isEnabled = true
                    button1.title = "Install \(item.name)"
                    
                case .uptodate:
                    
                    button1.isHidden = true
                    button1.isEnabled = true
                    
                case .outdated:
                    
                    button1.isHidden = false
                    button1.isEnabled = true
                    button1.title = "Update \(item.name)"
                    
                case .installing:
                    
                    button1.isHidden = false
                    button1.isEnabled = false
                    button1.title = "Installing..."
                    
                case .comingSoon:
                    
                    button1.isHidden = true
                    button1.isEnabled = true
                    
                }
                return buttonView
                
            default:
                
                print("Unknown column id: \(identifier)")
                assertionFailure()
            }
            
        } else if let item = item as? DependencyViewModel {
            
            switch identifier {
            case "DependencyColumn":
                
                view.imageView?.image = item.image
                view.textField?.stringValue = item.displayName
                
            case "VersionColumn":
                
                view.textField?.stringValue = item.version ?? ""
                
            case "PathColumn":
                
                view.textField?.stringValue = item.path ?? ""
                
            case "ActionColumn":
                
                // Fetch the view with two buttons
                guard let buttonView: NSTableCellView = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ActionCell"), owner: self) as? NSTableCellView else {
                    return nil
                }
                
                let button1: NSButton = buttonView.subviews.filter { $0.identifier!.rawValue == "Button1" }.first! as! NSButton
                
                switch item.state {
                    
                case .unknown, .notInstalled:
                    
                    button1.isHidden = false
                    button1.isEnabled = true
                    button1.title = "Install \(item.name)"
                    
                case .uptodate:
                    
                    button1.isHidden = true
                    button1.isEnabled = true
                    
                case .outdated:
                    
                    button1.isHidden = false
                    button1.isEnabled = true
                    button1.title = "Update \(item.name)"
                    
                case .installing:
                    
                    button1.isHidden = false
                    button1.isEnabled = false
                    button1.title = "Installing..."
                    
                case .comingSoon:
                    
                    button1.isHidden = true
                    button1.isEnabled = true
                    
                }
                return buttonView
                
            default:
                
                print("Unknown column id: \(identifier)")
                assertionFailure()
            }
        }
                
        return view
        
    }

    func selectionShouldChange(in outlineView: NSOutlineView) -> Bool {
        return false
    }
}

extension InstallBlockchainViewController: NSOutlineViewDataSource {
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        
        // Root
        guard let item = item as? DependencyViewModelProtocol else { return platforms.count }
        
        return item.children?.count ?? 0
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        
        guard let item = item as? DependencyViewModelProtocol, let children = item.children else { return false }
        
        return !children.isEmpty
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        
        // Root
        guard let item = item as? DependencyViewModelProtocol else { return platforms[index] }
        
        return item.children![index]
    }
}
