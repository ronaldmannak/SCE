//
//  EditWindowController.swift
//  SCE-Mac
//
//  Created by Ronald "Danger" Mannak on 8/11/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Cocoa

class EditWindowController: NSWindowController {
    
    var project: Project? = nil {
        didSet {
            guard let project = project else { return }
            do {
            try fileBrowserViewController.load(url: project.baseDirectory, projectName: project.name)
            } catch {
                let alert = NSAlert(error: error)
                alert.runModal()
            }
        }
    }
    
    var consoleTextView: NSTextView {
        return (self.window?.contentViewController?.childViewControllers[1] as! SplitViewController).consoleView
    }
    
    var fileBrowserViewController: FileBrowserViewController {
        return (self.window?.contentViewController! as! NSSplitViewController).childViewControllers[0] as! FileBrowserViewController
    }

    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    /// Sets console vc text. Called by PreparingViewController
    func setConsole(_ string: String) {
        consoleTextView.string = string
        
        let range = NSRange(location:consoleTextView.string.count,length:0)
        consoleTextView.scrollRangeToVisible(range)
    }

    @IBAction func runButtonClicked(_ sender: Any) {
        
//        guard let vc = contentViewController as? SplitViewController else {
//            exit(1)
//        }
//        vc.runCommand("ls")
    }

}
