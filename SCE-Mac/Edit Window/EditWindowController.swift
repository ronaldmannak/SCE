//
//  EditWindowController.swift
//  SCE-Mac
//
//  Created by Ronald "Danger" Mannak on 8/11/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Cocoa
import SavannaKit

class EditWindowController: NSWindowController {
    
    @IBOutlet weak var runButton: NSToolbarItem!
    
    var script: ScriptTask? = nil
    var editorURL: URL? = nil
    
    var project: Project? = nil {
        didSet {
            guard let project = project else { return }
            window?.title = project.name            
            do {
            try fileBrowserViewController.load(url: project.workDirectory, projectName: project.name)
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
    
    private var editView: SyntaxTextView {
        return (self.window?.contentViewController?.childViewControllers[1] as! SplitViewController).editorView
    }

    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
    
    /// Sets console vc text. Called by PreparingViewController
    func setConsole(_ string: String) {
        consoleTextView.string = consoleTextView.string + "\n" + string
        
        let range = NSRange(location:consoleTextView.string.count,length:0)
        consoleTextView.scrollRangeToVisible(range)
    }
    
    func setEditor(url: URL) {
        do {
            let text = try String(contentsOf: url)
            saveEditorFile()
            editView.text = text
            editorURL = url
        } catch {
            let alert = NSAlert(error: error)
            alert.runModal()
        }
    }
    
    func saveEditorFile() {
        guard let editorURL = editorURL else {
            return
        }
        do {
            try editView.text.write(to: editorURL, atomically: true, encoding: .utf8)
        } catch {
            let alert = NSAlert(error: error)
            alert.runModal()
        }
    }

    @IBAction func runButtonClicked(_ sender: Any) {

        guard let project = project else { return }
        saveEditorFile()
        script?.terminate()
        
        (sender as! NSButton).isEnabled = false
        do {
            script = try ScriptTask.run(project: project, output: { output in
                self.setConsole(output)
            }) {
                (sender as! NSButton).isEnabled = true
                //            open Safari http://127.0.0.1:7545
            }
        } catch {
            let alert = NSAlert(error: error)
            alert.runModal()
            (sender as! NSButton).isEnabled = true
        }

    }

    @IBAction func pauseButtonClicked(_ sender: Any) {
        script?.terminate()
        script = nil
        setConsole("Cancelled.")
        runButton.isEnabled = true
    }
}
