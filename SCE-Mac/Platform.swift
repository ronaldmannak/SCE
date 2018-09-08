//
//  Platform.swift
//  SCE-Mac
//
//  Created by Ronald "Danger" Mannak on 9/5/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation

enum Platform: String, Codable, CustomStringConvertible {
    
    case ethereum, ethereumclassic, bitcoin, cosmos, stellar
    
    var languages: [String] {
        switch self {
        case .ethereum, .ethereumclassic:
            return ["Solidity"]
        case .bitcoin:
            return ["Bitcoin Script"]
        case .cosmos:
            return ["Michelson"]
        case .stellar:
            return ["JavaScript", "Java", "Go"]
        }
    }
    
    var description: String {
        switch self {
        case .ethereumclassic:
            return "Ethereum Classic"
        case .cosmos:
            return "Tendermint Cosmos"
        default:
            // Capitalize first letter
            return self.rawValue.capitalizedFirstChar()
        }
    }
}
