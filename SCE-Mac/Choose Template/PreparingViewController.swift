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
    
    /// E.g. ~/Development/MyToken
    var path: String = "" {
        didSet {
            textView.string = path
        }
    }
    
    /// E.g. BasicToken
    var templateName: String = ""
    
    /// Name of bash script embedded in executable. E.g. TruffleScript
    var scriptFilename: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func executeScript(url: URL, projectname: String, templatename: String, scriptname: String) {
        print(url)
//        assert(url.hasDirectoryPath) // Making sure we're passed a directory
//        print(url.baseURL!)
        
    }
    
//    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
//        self.view.window!.close()
//    }
    
}
