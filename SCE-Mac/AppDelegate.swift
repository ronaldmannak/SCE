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
        // Insert code here to initialize your application
        
        if true == true { // TODO: Read UserDefaults for show Choose Template
            showChooseTemplate(self)
        }
        
        // Close
//        NSApplication.shared.windows.last!.close()
        
        // Set menu
        
        // Set first window
        
        
//        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
//        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        var exampleViewController: ExampleViewController = mainStoryboard.instantiateViewControllerWithIdentifier("ExampleController") as! ExampleViewController
//        
//        self.window?.rootViewController = exampleViewController
//        
//        self.window?.makeKeyAndVisible()
//        
//        return true
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
    
    @IBAction func showChooseTemplate(_ sender: Any) {
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Template"), bundle: nil)
        let templateController = storyboard.instantiateInitialController() as? NSWindowController
        templateController?.showWindow(sender)
    }
}

