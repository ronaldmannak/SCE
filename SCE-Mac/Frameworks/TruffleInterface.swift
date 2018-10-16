//
//  TruffleInterface.swift
//  SCE
//
//  Created by Ronald "Danger" Mannak on 9/20/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation

struct TruffleInterface: FrameworkInterfaceProtocol {
    var initFileURL: URL
    
    static let name: String = "Truffle"
    
    let platform: Platform
    
    init(_ platform: Platform) {
        self.initFileURL = URL(fileURLWithPath: "")
        self.platform = platform
    }
    
    func run() {
        
    }
    
    func lint() {
        
    }
    
    func debug() {
        
    }
    
}
