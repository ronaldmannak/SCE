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
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
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
        print("is changing \(category.selectedRow)")
        // update collectionview
    }
    
//    func tableViewSelectionDidChange(_ notification: Notification) {
//        print("Did change")
//    }
}
