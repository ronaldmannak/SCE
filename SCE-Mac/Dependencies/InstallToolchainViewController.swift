//
//  InstallToolchainViewController.swift
//  SCE-Mac
//
//  Created by Ronald "Danger" Mannak on 9/7/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Cocoa

class InstallToolchainViewController: NSViewController {
    
    @IBOutlet weak var platformCollectionView: NSCollectionView!
    @IBOutlet weak var outlineView: NSOutlineView!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var showOnStartupButton: NSButton!
    
    // Framework detail view
    @IBOutlet weak var detailImageView: NSImageView!
    @IBOutlet weak var detailLabel: NSTextField!
    @IBOutlet weak var detailInfoLabel: NSTextField!
    
    /// Queue used to fetch versions (which can be extremely slow)
    let fetchVersionQueue: OperationQueue = OperationQueue()
    
    /// Queue used to install and update tools
    let installQueue: OperationQueue = OperationQueue()
    
    /// KVO for installQueue.operationCount
    /// If operationCount is greater than zero,
    /// the progress indicator will animate
    private var installCount: NSKeyValueObservation?
    
    private var platforms = [DependencyPlatform]() {
        didSet {
            platformCollectionView.reloadData()
            platformCollectionView.selectItems(at: [IndexPath(item: 0, section: 0)], scrollPosition: .top)
            frameworkViewModels = platforms.first?.frameworkViewModels ?? [DependencyFrameworkViewModel]()
        }
    }
    
    private var frameworkViewModels = [DependencyFrameworkViewModel]() {
        didSet {
            outlineView.reloadData()
            outlineView.expandItem(nil, expandChildren: true) // expand all items
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchVersionQueue.maxConcurrentOperationCount = 1
        fetchVersionQueue.qualityOfService = .userInteractive
        installQueue.maxConcurrentOperationCount = 1
        installQueue.qualityOfService = .userInitiated
        
        installCount = installQueue.observe(\OperationQueue.operationCount, options: .new) { queue, change in
            if queue.operationCount == 0 {
                self.progressIndicator.stopAnimation(self)
                self.progressIndicator.isHidden = true
            } else {
                self.progressIndicator.startAnimation(self)
                self.progressIndicator.isHidden = false
            }
        }
        
        showOnStartupButton.state = UserDefaults.standard.bool(forKey: UserDefaultStrings.doNotShowDependencyWizard.rawValue) == false ? .on : .off
        
        configurePlatformCollectionView()
        loadPlatforms()
    }
    
    func loadPlatforms() {
        
        do {
            // Load dependencies from disk
            platforms = try DependencyPlatform.loadPlatforms()
            
//            outlineView.reloadData()
            
            /*
            // Fetch version numbers
            for platform in platforms {
                
                guard let frameworks = platform.children else { continue }
                for framework in frameworks {
                    
                    guard let tools = framework.children else { continue }
                    for tool in tools {

                        if let versionOperation = tool.versionQueryOperation() {
                            fetchVersionQueue.addOperation(versionOperation)
                            
                            versionOperation.completionBlock = {
                                DispatchQueue.main.async {
                                    guard versionOperation.exitStatus == 0 else { return }
                                    _ = tool.versionQueryParser(versionOperation.output)
                                    self.outlineView.reloadItem(framework)
                                    self.outlineView.reloadItem(tool)
                                }
                            }
                        }
                    }
                }
            } */
        } catch {
            let alert = NSAlert(error: error)
            alert.runModal()
        }
        
        
    }
    
    func configurePlatformCollectionView() {
        view.wantsLayer = true
        
        let nib = NSNib(nibNamed: NSNib.Name(rawValue: "PlatformCollectionViewItem"), bundle: nil)
        platformCollectionView.register(nib, forItemWithIdentifier: NSUserInterfaceItemIdentifier("PlatformCollectionViewItem"))
        
        platformCollectionView.reloadData()
    }
    
    @IBAction func done(_ sender: Any) {
        fetchVersionQueue.cancelAllOperations()
        view.window?.close()
        guard let delegate = NSApplication.shared.delegate as? AppDelegate else { return }
        delegate.showChooseTemplate(self)
    }
    
    @IBAction func cellButton(_ sender: Any) {
        // NSButton is a subclass of NSView
        guard let sender = sender as? NSView else { return }
        let row = outlineView.row(for: sender)

//        guard let item = outlineView.item(atRow: row) as? DependencyViewModelProtocol else { return }
//        
//        run(item)
    }
    
    @IBAction func showOnStartup(_ sender: Any) {
        guard let sender = sender as? NSButton else { return }
        UserDefaults.standard.set(sender.state == .off, forKey: UserDefaultStrings.doNotShowDependencyWizard.rawValue)            
    }
    
    @IBAction func platformMoreInfoButtonClicked(_ sender: Any) {
        
        guard let sender = sender as? NSView,
            let itemView = sender.nextResponder?.nextResponder as? PlatformCollectionViewItem,
            let indexPath = platformCollectionView.indexPath(for: itemView)
            else { return }

        // Select cell
        platformCollectionView.deselectAll(self)
        platformCollectionView.reloadData()
        platformCollectionView.selectItems(at: [indexPath], scrollPosition: .top)
        
        // Open url
        let platform = platforms[indexPath.item]
        guard let url = URL(string: platform.projectUrl) else { return }
        NSWorkspace.shared.open(url)
    }
    
//    func run(_ item: DependencyViewModelProtocol) {
        /*
        let catchClosure: (Error) -> Void = { error in
            self.outlineView.reloadData()
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

        let finish: (Int) -> Void = { exitCode in
//            do {
//                try item.updateVersion { _ in
//                    self.outlineView.reloadData()
//                }
//            } catch {
//                catchClosure(error)
//            }
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
        }*/
//    }
}

extension InstallToolchainViewController: NSOutlineViewDelegate {
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        
        guard let identifier = tableColumn?.identifier.rawValue else { return nil }
        
        guard let view: NSTableCellView = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "NameCell"), owner: self) as? NSTableCellView else {
            return nil
        }
        
        if let item = item as? DependencyFrameworkViewModel {
            
            switch identifier {
            case "DependencyColumn":
                
                view.imageView?.image = nil
                view.textField?.stringValue = item.displayName
                
            case "VersionColumn":
                
                view.textField?.stringValue = "(version)" // item.version ?? ""
                
            case "PathColumn":
                
                view.textField?.stringValue = "(path)" //item.path ?? ""
                
            case "ActionColumn":
                
                // Fetch the view with two buttons
                guard let buttonView: NSTableCellView = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ActionCell"), owner: self) as? NSTableCellView else {
                    return nil
                }
                
                let cellButton: NSButton = buttonView.subviews.filter { $0.identifier!.rawValue == "Button1" }.first! as! NSButton
                
                switch item.state {
                    
                case .notInstalled:
                    
                    cellButton.isHidden = false
                    cellButton.isEnabled = true
                    cellButton.title = "Install \(item.name)"
                    
                case .outdated, .unknown, .uptodate:
                    
                    cellButton.isHidden = false
                    cellButton.isEnabled = true
                    cellButton.title = "Update \(item.name)"
                    
                case .installing:
                    
                    cellButton.isHidden = false
                    cellButton.isEnabled = false
                    cellButton.title = "Installing..."
                    
                case .comingSoon:
                    
                    cellButton.isHidden = true
                    cellButton.isEnabled = true
                    
                }
                return buttonView
                
            default:
                
                print("Unknown column id: \(identifier)")
                assertionFailure()
            }
            
        } else if let item = item as? DependencyViewModel {
            
            switch identifier {
            case "DependencyColumn":
                
//                view.imageView?.image = item.image
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
                
                let cellButton: NSButton = buttonView.subviews.filter { $0.identifier!.rawValue == "Button1" }.first! as! NSButton
                
                switch item.state {
                    
                case .notInstalled:
                    
                    cellButton.isHidden = false
                    cellButton.isEnabled = true
                    cellButton.title = "Install \(item.name)"
                    
                case .uptodate:
                    
                    cellButton.isHidden = true
                    cellButton.isEnabled = true
                    
                case .outdated, .unknown:
                    
                    cellButton.isHidden = false
                    cellButton.isEnabled = true
                    cellButton.title = "Update \(item.name)"
                    
                case .installing:
                    
                    cellButton.isHidden = false
                    cellButton.isEnabled = false
                    cellButton.title = "Installing..."
                    
                case .comingSoon:
                    
                    cellButton.isHidden = true
                    cellButton.isEnabled = true
                    
                }
                return buttonView
                
            default:
                
                print("Unknown column id: \(identifier)")
                assertionFailure()
            }
        }
                
        return view
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        
        // do show
        if let item = item as? DependencyFrameworkViewModel {
            detailLabel.stringValue = item.displayName
        } else if let item = item as? DependencyViewModel {
            print("dependency")
        }
        
        return false
    }
    
//    func selectionShouldChange(in outlineView: NSOutlineView) -> Bool {
//        return false
//    }
}

extension InstallToolchainViewController: NSOutlineViewDataSource {
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        
        // If item is nil, return number of frameworks
        guard let item = item as? DependencyFrameworkViewModel else { return frameworkViewModels.count }
        
        // If item is a framework, return number of dependencies in framework
        return item.dependencies.count
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        
        // Only frameworks are expandable
        guard let item = item as? DependencyFrameworkViewModel else { return false }
        
        // Return true if framework has dependencies
        return !item.dependencies.isEmpty
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        
        if item == nil {
            
            // If item is nil, this is the root
            return frameworkViewModels[index]
            
        } else if let framework = item as? DependencyFrameworkViewModel {
            
            // Return number of dependencies of the framework
            return framework.dependencies[index]
            
        } else {

            assertionFailure()
            return 0
        }
    }
}

extension InstallToolchainViewController: NSCollectionViewDelegate {
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        
        guard let index = indexPaths.first?.item else { return }
        frameworkViewModels = platforms[index].frameworkViewModels
    }
}

extension InstallToolchainViewController: NSCollectionViewDataSource {
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return platforms.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        
        guard let cell = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier("PlatformCollectionViewItem"), for: indexPath) as? PlatformCollectionViewItem else {
            return NSCollectionViewItem()
        }
        
        let platform = platforms[indexPath.item]
        cell.platformLabel.stringValue = platform.platform.description
        cell.logoImageView.image = NSImage(named: NSImage.Name(rawValue: platform.platform.description))
        return cell
    }
}
