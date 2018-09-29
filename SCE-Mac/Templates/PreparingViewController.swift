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

    var projectDirectoryCreator: ProjectDirectoryCreator! {
        didSet {
            progressIndicator.startAnimation(self)
            progressIndicator.maxValue = 8
            do {
                _ = try projectDirectoryCreator.create(output: { output in
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
                    let documentController = NSDocumentController.shared
                    documentController.openDocument(withContentsOf: self.projectDirectoryCreator.project.projectFileURL, display: true) { (document, wasAlreadyOpen, error) in
                        
                        if let error = error {
                            self.progressIndicator.stopAnimation(self)
                            let alert = NSAlert(error: error)
                            alert.runModal()
                        }

                        if let document = document as? Document, let editWindowController = document.editWindowController {
                            editWindowController.setConsole(self.textView.string)
//                            editWindowController.project = self.projectDirectoryCreator.project
                        }
                        self.view.window?.close()
                    }
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
        projectDirectoryCreator.scriptTask.terminate()
        view.window?.close()
    }    
}
