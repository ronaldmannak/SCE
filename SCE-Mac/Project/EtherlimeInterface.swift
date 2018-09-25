//
//  EtherlimeInterface.swift
//  SCE
//
//  Created by Ronald "Danger" Mannak on 9/20/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation

struct EtherlimeInterface: PlatformInterfaceProtocol {
    
    static let name: String = "Etherlime"
    
    let platform: Platform
    
    init(_ platform: Platform) {
        self.platform = platform
    }
//    
    func run() {
        
    }
    
    func lint() {
        
    }
    
    func debug() {
        
    }
    
    
}
