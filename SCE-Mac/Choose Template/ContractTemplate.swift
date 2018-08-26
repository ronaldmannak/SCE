//
//  ContractTemplate.swift
//  SCE-Mac
//
//  Created by Ronald "Danger" Mannak on 8/13/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation
import Cocoa

struct ContractPlatform: Codable {
    
    enum Platform: String, Codable {
        case Ethereum, Bitcoin, Cosmos
        
        var languages: [String] {
            switch self {
            case .Ethereum:
                return ["Solidity"]
            case .Bitcoin:
                return ["Bitcoin Script"]
            case .Cosmos:
                return ["Michelson"]
            }
        }
    }
    
    let platform: Platform
    var languages: [String] { return platform.languages }
    let categories: [ContractCategory]?
}


struct ContractCategory: Codable {
    let category: String
    let command: String         // E.g. init (%..)
    let templates: [ContractTemplate]?
}

struct ContractTemplate: Codable {
    
    /// E.g. "Basic Token"
    let name: String
    
    /// E.g. "basictoken" (name used by Truffle)
    let templateName: String
    
    /// E.g. ERC-20
    let standard: String
    
    let imageName: String
    var image: NSImage {
        let name = imageName.isEmpty ? "Doc" : imageName
        return NSImage(named: NSImage.Name(rawValue: name)) ?? NSImage()
    }

//    let filename: String
    // filename or name used to create the template in Zeppelin
}

extension ContractTemplate {
    
}
