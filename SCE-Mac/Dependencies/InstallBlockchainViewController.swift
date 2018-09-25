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
    @IBOutlet weak var showOnStartupButton: NSButton!
    
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
        showOnStartupButton.state = UserDefaults.standard.bool(forKey: UserDefaultStrings.doNotShowDependencyWizard.rawValue) == false ? .on : .off
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

        guard let item = outlineView.item(atRow: row) as? DependencyViewModelProtocol else { return }
        
        run(item)
    }
    
    @IBAction func showOnStartup(_ sender: Any) {
        guard let sender = sender as? NSButton else { return }
        UserDefaults.standard.set(sender.state == .off, forKey: UserDefaultStrings.doNotShowDependencyWizard.rawValue)            
    }
    
    //    @IBAction func button2(_ sender: Any) {
//        let openPanel = NSOpenPanel()
//        openPanel.beginSheetModal(for: self.view.window!) { (response) in
//            // TODO
//        }
//    }
    
    func run(_ item: DependencyViewModelProtocol) {
        
        let catchClosure: (Error) -> Void = { error in
        
            self.outlineView.reloadData()
            self.updateProgressIndicator()
            let alert = NSAlert(error: error)
            alert.runModal()
        }
        
        let showOutputInConsole: (String) -> Void = { output in

            let previousOutput = self.console.string
            let nextOutput = previousOutput + "\n" + output
            self.console.string = nextOutput
            let range = NSRange(location:nextOutput.count,length:0)
            self.console.scrollRangeToVisible(range)
        }

        let finish: () -> Void = {

            do {
                try item.updateVersion { _ in
                    self.outlineView.reloadData()
                    self.updateProgressIndicator()
                }
            } catch {
                catchClosure(error)
            }
        }
        
        do {
            
            let tasks: [ScriptTask]
            
            switch item.state {
            case .notInstalled:
                tasks = try item.install(output: showOutputInConsole, finished: finish)
            default:
                tasks = try item.update(output: showOutputInConsole, finished: finish)
            }
            
            for task in tasks {
                task.run()
            }
            self.outlineView.reloadData() // to show "installing"
            
        } catch {
            catchClosure(error)
        }
    }
}

// Queue functions
extension InstallBlockchainViewController {
    
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
                guard !item.frameworks.isEmpty else {
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
                    
                case .notInstalled:
                    
                    button1.isHidden = false
                    button1.isEnabled = true
                    button1.title = "Install toolchain"
                    
                case .uptodate, .outdated, .unknown:
                    
                    button1.isHidden = false
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
                    
                case .notInstalled:
                    
                    button1.isHidden = false
                    button1.isEnabled = true
                    button1.title = "Install \(item.name)"
                    
                case .outdated, .unknown, .uptodate:
                    
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
                    
                case .notInstalled:
                    
                    button1.isHidden = false
                    button1.isEnabled = true
                    button1.title = "Install \(item.name)"
                    
                case .uptodate:
                    
                    button1.isHidden = true
                    button1.isEnabled = true
                    
                case .outdated, .unknown:
                    
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
