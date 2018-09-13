//
//  PreferencesLocationsGeneralViewController.swift
//  SCE-Mac
//
//  Created by Ronald "Danger" Mannak on 9/8/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Cocoa

class PreferencesLocationsGeneralViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func openInstall(_ sender: Any) {
        view.window?.close()
        guard let delegate = NSApplication.shared.delegate as? AppDelegate else { return }
        do {
            let setup = try DependencySetup()
            delegate.showInstallWizard(setup: setup)
        } catch {
            let alert = NSAlert(error: error)
            alert.runModal()
        }
    }
}
