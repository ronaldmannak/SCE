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
    
    let categories = ["    All", "    Token", "    Payment", "    Crowdsale"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        category.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
    }
    
    @IBAction func ChooseClicked(_ sender: Any) {
        
        let savePanel = NSSavePanel() 
        savePanel.beginSheetModal(for: view.window!) { (result) in
            if result == .OK {
                print("OK")
            }
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
}

extension ChooseTemplateViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return categories[row]
    }
}

extension ChooseTemplateViewController: NSTableViewDelegate {
    func tableViewSelectionIsChanging(_ notification: Notification) {
//        print("is changing \(category.selectedRow)")
        // update collectionview
    }
}
