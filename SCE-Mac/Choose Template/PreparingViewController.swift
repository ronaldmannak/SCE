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
    private var script: ScriptTask?
    var projectCreator: ProjectCreator!
    
    /// E.g. BasicToken
    var templateName: String = ""
    
    /// Name of bash script embedded in executable. E.g. TruffleScript
    var scriptFilename: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        executeScript(url: URL(string: "test")!, projectname: "", templatename: "", scriptname: "")
    }
    
    private func executeScript(url: URL, projectname: String, templatename: String, scriptname: String) {
        print(url)
        script = ScriptTask.truffleInit(path: url, projectname: projectname, templatename: templatename, output: { (output) in
            // Output in text view
            let previousOutput = self.textView.string
            let nextOutput = previousOutput + "\n" + output
            self.textView.string = nextOutput
            let range = NSRange(location:nextOutput.characters.count,length:0)
            self.textView.scrollRangeToVisible(range)
        }) {
            print("***** FINISHED ********")
////            let id = NSStoryboardSegue.Identifier(rawValue: "EditWindow")
////            self.performSegue(withIdentifier: id, sender: self)
////            view.window?.close()
        }
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
        print(script ?? "nil script")
        print(script?.notification ?? "nil notification")
//        script?.terminate()
//        view.window?.close()
    }
    
    
    //    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
//        self.view.window!.close()
//    }
    
}
