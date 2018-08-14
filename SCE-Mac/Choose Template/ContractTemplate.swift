//
//  ContractTemplate.swift
//  SCE-Mac
//
//  Created by Ronald "Danger" Mannak on 8/13/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation

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
    let command: String         // E.g. init (%..)
}

struct ContractCategory: Codable {
    let name: String
    let templates: [ContractTemplate]
}

struct ContractTemplate: Codable {
    
    let name:String         // E.g. "Basic Token"
    let standard: String?   // E.g. ERC-20
    let filename: String
    // filename or name used to create the template in Zeppelin
}
