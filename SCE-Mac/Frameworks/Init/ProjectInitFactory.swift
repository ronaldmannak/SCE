//
//  ProjectInitFactory.swift
//  SCE
//
//  Created by Ronald "Danger" Mannak on 10/4/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation

struct ProjectInitFactory {
    
    static func create(projectname: String, baseDirectory: URL, platform: Platform, framework: String, template: Template? = nil, info: Any? = nil) throws -> ProjectInitProtocol {
    
        let project = Project(name: projectname, platformName: platform.rawValue, frameworkName: framework, lastOpenFile: nil)
        switch platform {
        case .ethereum:
            switch framework.lowercased() {
//            case "etherlime":
//                return EtherlimeInit()
            case "truffle":
                return try TruffleInit(project: project, baseDirectory: baseDirectory, template: template, info: info)
            default:
                fatalError("Not implemented yet")
            }
        default:
            fatalError("Not implemented yet")
        }
    }
    
    static func create(projectInit: ProjectInitProtocol, info: Any?) {
        
    }
}
