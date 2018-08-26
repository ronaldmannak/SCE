//
//  ChooseTemplateViewController.swift
//  SCE-Mac
//
//  Created by Ronald "Danger" Mannak on 8/12/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Cocoa

class ChooseTemplateViewController: NSViewController {

    @IBOutlet weak var platform: NSPopUpButton!
    @IBOutlet weak var language: NSPopUpButton!
    @IBOutlet weak var category: NSTableView!
    @IBOutlet weak var template: NSCollectionView!
    
    /// Project to be created
    var categories = [ContractCategory]()
    var projectCreator: ProjectCreator? = nil
    let allRowIndex = 0 // All categories
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            categories = try loadCategory(filename: "EthereumTruffle")
            print (category)
        } catch {
            let alert = NSAlert(error: error)
            alert.runModal()
        }
        
        configureTemplateView()
        category.reloadData()
        category.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
        template.reloadData()
        // Without a delay, the first cell gets selected, but the background isn't highlighted
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.template.selectItems(at: [IndexPath(item: 0, section: 0)], scrollPosition: .top)
        }
    }
    
    /// filename without JSON extension
    func loadCategory(filename: String) throws -> [ContractCategory] {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            throw(EditorError.fileNotFound(filename))
        }
        let jsonData = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let category = try decoder.decode([ContractCategory].self, from: jsonData)
        return category
    }
    
    @IBAction func ChooseClicked(_ sender: Any) {
        
        let savePanel = NSSavePanel()
        savePanel.beginSheetModal(for: view.window!) { (result) in

            guard result == .OK, let directory = savePanel.url else { return }
            
            // Temporary: do not allow overwriting existing files or directories
            let fileManager = FileManager.default
            guard fileManager.fileExists(atPath: directory.path) == false else { return }

            let projectName = directory.lastPathComponent
            let baseDirectory = directory.deletingLastPathComponent()
            
            guard let selectedIndex = self.template.selectionIndexPaths.first else { return }
            let selectedTemplate = self.itemAt(selectedIndex)
            let templateName = selectedTemplate.templateName.isEmpty ? selectedTemplate.name : selectedTemplate.templateName
            let selectedCategory = self.categories[selectedIndex.section]
            
            let project = Project(name: projectName, baseDirectory: baseDirectory)
            self.projectCreator = ProjectCreator(templateName: templateName, installScript: selectedCategory.command, project: project)
            
            let id = NSStoryboardSegue.Identifier(rawValue: "PreparingSegue")
            self.performSegue(withIdentifier: id, sender: self)
        }
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
        self.view.window!.close()
    }
    
    @IBAction func platformClicked(_ sender: Any) {
        switch (sender as! NSPopUpButton).selectedItem!.title {
        case "Ethereum":
            language.selectItem(at: 0)
        case "Bitcoin":
            language.selectItem(at: 1)
        case "Cosmos":
            language.selectItem(at: 2)
        default:
            fatalError()
        }
    }
    
    @IBAction func languageClicked(_ sender: Any) {
    }

    /// Set up PreparingViewController
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        assert(projectCreator != nil)
        
        let preparingViewController = ((segue.destinationController as! NSWindowController).contentViewController! as! PreparingViewController)
        preparingViewController.projectCreator = projectCreator
        self.view.window!.close()
    }
}

extension ChooseTemplateViewController: NSCollectionViewDataSource, NSCollectionViewDelegate {
    
    fileprivate func itemAt(_ indexPath: IndexPath) -> ContractTemplate {
        if category.selectedRow == allRowIndex {
            return categories[indexPath.section].templates![indexPath.item]
        } else {
            return categories[category.selectedRow - 1].templates![indexPath.item]
        }
    }
    
    fileprivate func configureTemplateView() {
        view.wantsLayer = true
        let nib = NSNib(nibNamed: NSNib.Name(rawValue: "TemplateCollectionViewItem"), bundle: nil)
        template.register(nib, forItemWithIdentifier: NSUserInterfaceItemIdentifier("TemplateCollectionViewItem"))
    }
    
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        if category.selectedRow == allRowIndex {
            return categories.count // All
        } else {
            return 1 // Show only selected category
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        if category.selectedRow == allRowIndex {
            return categories[section].templates?.count ?? 0
        }
        return categories[category.selectedRow - 1].templates?.count ?? 0
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        
        guard let cell = template.makeItem(withIdentifier: NSUserInterfaceItemIdentifier("TemplateCollectionViewItem"), for: indexPath) as? TemplateCollectionViewItem else {
            assertionFailure()
            return NSCollectionViewItem()
        }

        let item = itemAt(indexPath)
        
        cell.imageView?.image = item.image
        cell.textField?.stringValue = item.name
        cell.erc.stringValue = item.standard
        return cell
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        print(indexPaths)
    }
    
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
        template.reloadData()
        template.selectItems(at: [IndexPath(item: 0, section: 0)], scrollPosition: .top)
    }
}
