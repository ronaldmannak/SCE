//
//  InstallCompleteViewController.swift
//  SCE-Mac
//
//  Created by Ronald "Danger" Mannak on 9/7/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Cocoa

class InstallCompleteViewController: NSViewController {

    weak var container: InstallContainerViewController!
    @IBOutlet weak var hopefulLabel: NSTextField!
    @IBOutlet weak var wrongLabel: NSTextField!
    
    var consoleContent: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hopefulLabel.isHidden = true
        wrongLabel.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.hopefulLabel.isHidden = false
        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            self.wrongLabel.isHidden = false
//        }
    }
    
    @IBAction func done(_ sender: Any) {
        view.window?.close()
        guard let delegate = NSApplication.shared.delegate as? AppDelegate else { return }
        delegate.showChooseTemplate(self)
    }
}
