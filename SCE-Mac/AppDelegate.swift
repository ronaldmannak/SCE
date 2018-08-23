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

    var preferencesController: PreferencesWindowController? = nil

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    
    @IBAction func showPreferences(_ sender: Any) {
        
        if preferencesController == nil {
            let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Preferences"), bundle: nil)
            preferencesController = storyboard.instantiateInitialController() as? PreferencesWindowController
        }
        
        if let preferencesController = preferencesController {
            preferencesController.showWindow(sender)
        }
    }
    
}

