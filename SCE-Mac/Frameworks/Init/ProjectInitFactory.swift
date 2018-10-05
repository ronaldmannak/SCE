//
//  ProjectInitFactory.swift
//  SCE
//
//  Created by Ronald "Danger" Mannak on 10/4/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation

struct ProjectInitFactory {
    
    static func create(platform: Platform, framework: String, template: Template?, projectFile: URL) throws -> ProjectInitProtocol {
    
        switch platform {
        case .ethereum:
            switch framework {
            case "etherlime":
                return EtherlimeInit()
            case "truffle":
                return TruffleInit()
            default:
                fatalError("Not implemented yet")
            }
        default:
            fatalError("Not implemented yet")
        }
    }
}
