//
//  SplitViewController.swift
//  SCE-Mac
//
//  Created by Ronald "Danger" Mannak on 8/2/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Cocoa
import SavannaKit
import SourceEditor

class SplitViewController: NSSplitViewController {

    let lexer = SolidityLexer()
    var editorView: SyntaxTextView!
    var consoleView: NSTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set editor view
        splitViewItems.first!.minimumThickness = 60
        editorView = splitViewItems.first!.viewController.view as! SyntaxTextView
//        syntaxTextView.text = "Hello!"
        editorView.theme = DefaultSourceCodeTheme()
//        SyntaxTextView.tintColor = Color(named: .white)
        editorView.delegate = self
        
        // Set consoleView
//        guard let v = splitViewItems.last!.viewController.view as? NSScrollView else { fatalError()}
//        guard let v2 = v.documentView as? NSTextView else { fatalError() }
        consoleView = {
            let scrollView = splitViewItems.last!.viewController.view as! NSScrollView
            return scrollView.documentView as! NSTextView
        }()
        if let result = run("ls") {
            consoleView.insertText(result)
            print(result)
        }
    }
    
}
