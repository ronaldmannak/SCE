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
    
//    private var selectedFramework: DependencyFramework {
//        let platform = platforms[platformPopup.indexOfSelectedItem] as! DependencyPlatformViewModel
//        return platform.frameworks[frameworkPopup.indexOfSelectedItem].framework
//    }
    
    fileprivate var categories = [TemplateCategory]() {
        didSet {
            categoryTableView.reloadData()
            templateCollectionView.reloadData()
            categoryTableView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
            templateCollectionView.selectItems(at: [IndexPath(item: 0, section: 0)], scrollPosition: .top)
        }
    }
    fileprivate var projectInit: ProjectInitProtocol? = nil
    
    /// Index for "All categories"
    fileprivate let allRowIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTemplateView()
        loadPlatforms()
        setTemplates()
    }
    
    
    /// Loads platforms and populates popup buttons
    private func loadPlatforms() {
        
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
    
    
    private func setTemplates() {
        
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
    private func loadTemplates(framework: String) throws -> [TemplateCategory] {
        guard let url = Bundle.main.url(forResource: "Templates-\(framework)", withExtension: "plist") else {
            throw(CompositeError.fileNotFound(framework))
        }
        let jsonData = try Data(contentsOf: url)
        let decoder = PropertyListDecoder()
        let category = try decoder.decode([TemplateCategory].self, from: jsonData)
        return category
    }
    
    
    @IBAction func ChooseClicked(_ sender: Any) {
        
        guard let selection = templateCollectionView.selectionIndexPaths.first else { return }
        
        let template = item(at: selection)
//        guard let detailType = template.detailViewType, detailType.isEmpty == false else {
            // No detail type
            showSavePanel(template: template)
            return
//        }
//        container.showOptions()
    }
    
    
    @IBAction func cancelClicked(_ sender: Any) {
        self.view.window!.close()
    }
    
    @IBAction func viewMoreInfoClicked(_ sender: Any) {
        guard let sender = sender as? NSView,
            let itemView = sender.nextResponder?.nextResponder as? TemplateCollectionViewItem,
            let indexPath = templateCollectionView.indexPath(for: itemView)
            else { return }

        let template = item(at: indexPath)
        guard let url = URL(string: template.moreInfoUrl) else { return }
        NSWorkspace.shared.open(url)
        // Nice to have: select cell so user have confirmation which "more info" button they clicked
//        templateCollectionView.deselectAll(self)
//        templateCollectionView.selectItems(at: [indexPath], scrollPosition: .top)
    }
    
    
    @IBAction func emptyProjectClicked(_ sender: Any) {
        showSavePanel()
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
        guard let projectInit = projectInit else { return }
        
        if let destination = segue.destinationController as? NSWindowController, let projectInitWindow = destination.contentViewController as? ProjectInitViewController {
            projectInitWindow.projectInit = projectInit
        } else {
            print("Here")
        }
        self.view.window!.close()
    }
    
    
    private func showSavePanel(template: Template? = nil) {
        
        let savePanel = NSSavePanel()
        savePanel.beginSheetModal(for: view.window!) { (result) in
            
            guard result == .OK, let directory = savePanel.url else { return }
            
            // Temporary: do not allow overwriting existing files or directories
            let fileManager = FileManager.default
            guard fileManager.fileExists(atPath: directory.path) == false else { return }
            
            let projectName = directory.lastPathComponent // e.g. "MyProject"
            let baseDirectory = directory.deletingLastPathComponent() // e.g. "/~/Documents/"
            
            guard let projectInit = self.createProjectInit(projectname: projectName, baseDirectory: baseDirectory, template: template) else { return }
            self.projectInit = projectInit
            
            let id = NSStoryboardSegue.Identifier(rawValue: "ProjectInitSegue")
            self.performSegue(withIdentifier: id, sender: self)
        }
    }
    
    private func createProjectInit(projectname: String, baseDirectory: URL, template: Template? = nil) -> ProjectInitProtocol? {
        
        let selectedPlatformViewModel = platforms[platformPopup.indexOfSelectedItem] as! DependencyPlatformViewModel
        let selectedPlatform = selectedPlatformViewModel.platformDependency.platform
        let selectedFrameworkName = selectedPlatformViewModel.frameworks[frameworkPopup.indexOfSelectedItem].framework.name
        
        do {
            let projectInit = try ProjectInitFactory.create(projectname: projectname ,baseDirectory: baseDirectory, platform: selectedPlatform, framework: selectedFrameworkName, template: template, info: nil)
            return projectInit
        } catch {
            let alert = NSAlert(error: error)
            alert.runModal()
        }
        return nil
    }
}


extension ChooseTemplateViewController: NSCollectionViewDataSource, NSCollectionViewDelegate {
    
    fileprivate func item(at indexPath: IndexPath) -> Template {
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

        let template = item(at: indexPath)

        cell.imageView?.image = template.image
        cell.textField?.stringValue = template.name
        cell.erc.stringValue = template.standard
        cell.descriptionTextField.stringValue = template.description ?? ""
        cell.moreInfoButton.isHidden = template.moreInfoUrl.isEmpty
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
