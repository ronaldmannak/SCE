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
        category.reloadData()
        
        category.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
        configureTemplateView()
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

            guard result == .OK, let directory = savePanel.url else {  //directory.hasDirectoryPath == true else {
                assertionFailure()
                return
            }
            
            let projectName = directory.lastPathComponent
            let baseDirectory = directory.deletingLastPathComponent()
            
            let project = Project(name: projectName, baseDirectory: baseDirectory)
            self.projectCreator = ProjectCreator(templateName: "tutorialtoken", installScript: "TruffleInit", project: project)
            
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
//        if category.selectedRow == 0 {
//        }

        return template.makeItem(withIdentifier: NSUserInterfaceItemIdentifier("TemplateCollectionViewItem"), for: indexPath)
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        print(indexPaths)
    }
    
    // header?
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
    }
}
