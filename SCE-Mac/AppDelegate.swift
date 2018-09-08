//
//  AppDelegate.swift
//  SCE-Mac
//
//  Created by Ronald "Danger" Mannak on 8/1/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

//    var preferencesController: PreferencesWindowController? = nil

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        var setup: DependencySetup!
        var shouldDisplayInstallWizard = false
        do {
            setup = try DependencySetup()
            shouldDisplayInstallWizard = try setup.setup(.ethereum, overwrite: true)         
        } catch {
            let alert = NSAlert(error: error)
            alert.runModal()
        }
  
        if shouldDisplayInstallWizard == true {
            showInstallWizard(setup: setup)
        } else {
            showChooseTemplate(self)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    
//    @IBAction func showPreferences(_ sender: Any) {
//        
//        if preferencesController == nil {
//            let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Preferences"), bundle: nil)
//            preferencesController = storyboard.instantiateInitialController() as? PreferencesWindowController
//        }
//        
//        if let preferencesController = preferencesController {
//            preferencesController.showWindow(sender)
//        }
//    }
    
    func showInstallWizard(setup: DependencySetup) {
        let installWizardStoryboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "InstallWizard"), bundle: nil)
        let installWizard = installWizardStoryboard.instantiateInitialController() as? NSWindowController
        let installContainer = installWizard?.contentViewController as? InstallContainerViewController
        installContainer?.dependencies = setup
        installWizard?.showWindow(self)
    }
    
    @IBAction func showChooseTemplate(_ sender: Any) {
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Template"), bundle: nil)
        let templateController = storyboard.instantiateInitialController() as? NSWindowController
        templateController?.showWindow(sender)
    }
}

