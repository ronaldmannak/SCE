//
//  PreparingViewController.swift
//  SCE-Mac
//
//  Created by Ronald "Danger" Mannak on 8/14/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Cocoa

class PreparingViewController: NSViewController {
    
    @IBOutlet var textView: NSTextView!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    @IBOutlet weak var cancelButton: NSButton!
    var counter: Int = 0

    var projectCreator: ProjectCreator! {
        didSet {
            progressIndicator.startAnimation(self)
            progressIndicator.maxValue = 8
            do {
                _ = try projectCreator.create(output: { output in
                    // Output in text view
                    let previousOutput = self.textView.string
                    let nextOutput = previousOutput + "\n" + output
                    self.textView.string = nextOutput
                    let range = NSRange(location:nextOutput.count,length:0)
                    self.textView.scrollRangeToVisible(range)
                    self.progressIndicator.increment(by: 1)
                    self.counter = self.counter + 1
                }) {
                    self.progressIndicator.stopAnimation(self)
//                    let id = NSStoryboardSegue.Identifier(rawValue: "EditWindowController")
//                    self.performSegue(withIdentifier: id, sender: self)
                    
                    let documentController = NSDocumentController.shared
                    documentController.openDocument(withContentsOf: self.projectCreator.project.projectFileURL, display: true) { (document, wasAlreadyOpen, error) in
//                        documentController.conto
//
//                        editWindowController.setConsole(textView.string)
//                        editWindowController.project = projectCreator.project
                        self.view.window?.close()
                    }

                    
//                    let document = NSDocumentController.shared.newDocument(self) as! Document
//                    document.project = self.projectCreator.project
                }
            } catch {
                self.progressIndicator.stopAnimation(self)
                let alert = NSAlert(error: error)
                alert.runModal()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
        projectCreator.scriptTask.terminate()
        view.window?.close()
    }

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        let editWindowController = (segue.destinationController as! EditWindowController)
//        editWindowController.setConsole(textView.string)
//        editWindowController.project = projectCreator.project
//        self.view.window?.close()
    }
    
}
