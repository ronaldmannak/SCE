//
//  ChooseTemplateViewController.swift
//  SCE-Mac
//
//  Created by Ronald "Danger" Mannak on 8/12/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Cocoa

class ChooseTemplateViewController: NSViewController {

    @IBOutlet weak var platformPopup: NSPopUpButton!
    @IBOutlet weak var frameworkPopup: NSPopUpButton!
    @IBOutlet weak var languagePopup: NSPopUpButton!
    @IBOutlet weak var categoryTableView: NSTableView!
    @IBOutlet weak var templateCollectionView: NSCollectionView!

    weak var container: TemplateContainerViewController!
    
    private var platforms:  [DependencyViewModelProtocol]!
    var categories = [TemplateCategory]() {
        didSet {
            categoryTableView.reloadData()
            templateCollectionView.reloadData()
            categoryTableView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
            templateCollectionView.selectItems(at: [IndexPath(item: 0, section: 0)], scrollPosition: .top)
        }
    }
    var projectDirectoryCreator: ProjectDirectoryCreator? = nil
    let allRowIndex = 0 // All categories
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTemplateView()
        loadPlatforms()
        setTemplates()
    }
    
    
    /// Loads platforms and populates popup buttons
    func loadPlatforms() {
        
        // Load dependencies from disk
        do {
            self.platforms = try DependencyPlatform.loadViewModels()
            if let framework = self.platforms.first?.children?.first as? DependencyFrameworkViewModel {
                categories = try loadTemplates(framework: framework.name)
            }
        } catch {
            let alert = NSAlert(error: error)
            alert.runModal()
        }
        
        platformPopup.removeAllItems()
        frameworkPopup.removeAllItems()
        
        let platforms = self.platforms as! [DependencyPlatformViewModel]
        for platform in platforms {
            self.platformPopup.addItem(withTitle: platform.name)
            self.platformPopup.item(withTitle: platform.name)?.isEnabled = !platform.frameworks.isEmpty
            for framework in platform.frameworks {
                self.frameworkPopup.addItem(withTitle: framework.name)
            }
        }
    }
    
    
    func setTemplates() {
        
        guard let framework = platforms[platformPopup.indexOfSelectedItem].children?[frameworkPopup.indexOfSelectedItem] as? DependencyFrameworkViewModel else { return }
        
        // Load templates
        do {
            categories = try loadTemplates(framework: framework.name)
        } catch {
            let alert = NSAlert(error: error)
            alert.runModal()
        }
    }
    
    
    /// filename without JSON extension
    func loadTemplates(framework: String) throws -> [TemplateCategory] {
        guard let url = Bundle.main.url(forResource: "Templates-\(framework)", withExtension: "plist") else {
            throw(EditorError.fileNotFound(framework))
        }
        let jsonData = try Data(contentsOf: url)
        let decoder = PropertyListDecoder()
        let category = try decoder.decode([TemplateCategory].self, from: jsonData)
        return category
    }
    
    
    @IBAction func ChooseClicked(_ sender: Any) {
        container.showOptions()
    }
    
    
    @IBAction func cancelClicked(_ sender: Any) {
        self.view.window!.close()
    }
    
    
    @IBAction func viewItemMoreInfoClicked(_ sender: Any) {
        print("click")
        guard let sender = sender as? NSView,
            let itemView = sender.nextResponder?.nextResponder as? TemplateCollectionViewItem,
            let indexPath = templateCollectionView.indexPath(for: itemView)
            else { return }

        let item = itemAt(indexPath)
        guard let url = URL(string: item.moreInfoUrl) else { return }        
        NSWorkspace.shared.open(url)
        // Nice to have: select cell so user have confirmation which "more info" button they clicked
//        templateCollectionView.deselectAll(self)
//        templateCollectionView.selectItems(at: [indexPath], scrollPosition: .top)
    }
    
    
    @IBAction func emptyProjectClicked(_ sender: Any) {
        let savePanel = NSSavePanel()
        savePanel.beginSheetModal(for: view.window!) { (result) in
            
                        guard result == .OK, let directory = savePanel.url else { return }
            
                        // Temporary: do not allow overwriting existing files or directories
                        let fileManager = FileManager.default
                        guard fileManager.fileExists(atPath: directory.path) == false else { return }
            
                        let projectName = directory.lastPathComponent
                        let baseDirectory = directory.deletingLastPathComponent()
            
            
            
//                        let project = Project(name: projectName, baseDirectory: baseDirectory, lastOpenFile: selectedTemplate.openFile)
//                        self.projectCreator = ProjectCreator(templateName: templateName, installScript: selectedCategory.command, project: project, copyFiles: selectedTemplate.copyFiles)
            
                        let id = NSStoryboardSegue.Identifier(rawValue: "PreparingSegue")
                        self.performSegue(withIdentifier: id, sender: self)
        }
    }
    
    
    @IBAction func platformClicked(_ sender: Any) {
        
        // Fetch selected Platform
        let selected = platforms[platformPopup.indexOfSelectedItem] as! DependencyPlatformViewModel
        
        // Populate Framework popups
        self.frameworkPopup.removeAllItems()
        for framework in selected.frameworks {
            self.frameworkPopup.addItem(withTitle: framework.name)
        }
        
        // Load new templates
        setTemplates()
    }
    
    @IBAction func frameworkClicked(_ sender: Any) {
        // Load templates of this framework
        setTemplates()
    }
    
    
    @IBAction func languageClicked(_ sender: Any) {
        setTemplates()        
    }

    
    /// Set up PreparingViewController
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        assert(projectDirectoryCreator != nil)
        
        let preparingViewController = ((segue.destinationController as! NSWindowController).contentViewController! as! PreparingViewController)
        preparingViewController.projectDirectoryCreator = projectDirectoryCreator
        self.view.window!.close()
    }
}


extension ChooseTemplateViewController: NSCollectionViewDataSource, NSCollectionViewDelegate {
    
    fileprivate func itemAt(_ indexPath: IndexPath) -> Template {
        if categoryTableView.selectedRow == allRowIndex {
            return categories[indexPath.section].templates![indexPath.item]
        } else {
            return categories[categoryTableView.selectedRow - 1].templates![indexPath.item]
        }
    }
    
    
    fileprivate func configureTemplateView() {
        view.wantsLayer = true
        let nib = NSNib(nibNamed: NSNib.Name(rawValue: "TemplateCollectionViewItem"), bundle: nil)
        templateCollectionView.register(nib, forItemWithIdentifier: NSUserInterfaceItemIdentifier("TemplateCollectionViewItem"))
    }
    
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        
        if categoryTableView.selectedRow == allRowIndex {
            return categories.count // All
        } else {
            return 1 // Show only selected category
        }
    }
    
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if categoryTableView.selectedRow == allRowIndex {
            return categories[section].templates?.count ?? 0
        }
        return categories[categoryTableView.selectedRow - 1].templates?.count ?? 0
    }
    
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {

        guard let cell = templateCollectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier("TemplateCollectionViewItem"), for: indexPath) as? TemplateCollectionViewItem else {
            assertionFailure()
            return NSCollectionViewItem()
        }

        let item = itemAt(indexPath)

        cell.imageView?.image = item.image
        cell.textField?.stringValue = item.name
        cell.erc.stringValue = item.standard
        cell.descriptionTextField.stringValue = item.description ?? ""
        cell.moreInfoButton.isHidden = item.moreInfoUrl.isEmpty
        return cell
    }
    
//    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
//     
//    }
    
//    func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind, at indexPath: IndexPath) -> NSView {
//        guard let header = template.makeSupplementaryView(ofKind: .sectionHeader, withIdentifier: NSUserInterfaceItemIdentifier("TemplateSectionHeader"), for: indexPath) as? TemplateSectionHeaderView else {
//            assertionFailure()
//            return NSCollectionView()
//        }
//        header.categoryNameTextField.stringValue = "TEST Header"
//        return header
//    }
}

extension ChooseTemplateViewController : NSCollectionViewDelegateFlowLayout {
    
//    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> NSSize {
//        return category.selectedRow == allRowIndex ? NSSize.zero : NSSize(width: 1000, height: 40)
//    }
}

extension ChooseTemplateViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return categories.count + 1 // all categories plus "All"
    }
    
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if row == allRowIndex { return "    All" }
        return "    " + categories[row - 1].category
    }
}

extension ChooseTemplateViewController: NSTableViewDelegate {
    
    func tableViewSelectionIsChanging(_ notification: Notification) {
        templateCollectionView.reloadData()
        templateCollectionView.selectItems(at: [IndexPath(item: 0, section: 0)], scrollPosition: .top)
    }
}
