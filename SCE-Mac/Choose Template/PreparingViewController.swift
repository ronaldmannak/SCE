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

    var projectCreator: ProjectCreator! {
        didSet {
            do {
                _ = try projectCreator.create(output: { output in
                    // Output in text view
                    let previousOutput = self.textView.string
                    let nextOutput = previousOutput + "\n" + output
                    self.textView.string = nextOutput
                    let range = NSRange(location:nextOutput.count,length:0)
                    self.textView.scrollRangeToVisible(range)
                }) {
                    let id = NSStoryboardSegue.Identifier(rawValue: "EditWindow")
                    self.performSegue(withIdentifier: id, sender: self)
                }
            } catch {
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
        (segue.destinationController as! EditWindowController).setConsole(textView.string)
        self.view.window?.close()
    }
    
}
