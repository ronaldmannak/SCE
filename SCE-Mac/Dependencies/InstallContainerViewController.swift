//
//  InstallContainerViewController.swift
//  SCE-Mac
//
//  Created by Ronald "Danger" Mannak on 9/7/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Cocoa

class InstallContainerViewController: NSViewController {

    weak var install: InstallBlockchainViewController!
    weak var complete: InstallCompleteViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        install = childViewControllers.first! as! InstallBlockchainViewController // Set in storyboard
        complete = storyboard?.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "Install")) as! InstallCompleteViewController
        addChildViewController(complete)
        
        install.container = self
        complete.container = self
    }
    
    func showComplete() {
        for subView in view.subviews {
            subView.removeFromSuperview()
        }
        view.addSubview(complete.view)
    }
}
