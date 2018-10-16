//
//  FrameworkInterface.swift
//  SCE
//
//  Created by Ronald "Danger" Mannak on 10/15/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation

class FrameworkInterface {
    
    init(frameworkName: String, frameworkVersion: String) throws {
        
        // 1. Parse FrameworkInterface.plist XML into dictionary
        let interfaceFile = Bundle.main.url(forResource: "FrameworkInterface", withExtension: "plist")!
        
        let data = try Data(contentsOf: interfaceFile)
//        let decoder = PropertyListDecoder()
//        let plist = try String(contentsOf: interfaceFile)
        
//        let dict = try XMLRea
        
//        func ReadXML(xml : String) {
//            do {
//                let dic = try? XMLReader.dictionary(forXMLString: xml)
//
//                let json = try? JSONSerialization.data(withJSONObject: dic! as [AnyHashable : Any], options: .prettyPrinted)
//
//                let resDic = try? JSONSerialization.jsonObject(with: json!, options: .allowFragments)
//
//                print(resDic)
//            } catch
//            {
//            }
//
//
//
//        let dict [String: Any] = [:]()
//        guard let frameworkVersions = dict[frameworkName] else {
//            throw CompositeError.frameworkNotFound(frameworkName)
//        }
//
//        // 2. Find exact version
//        if let exactVersion = frameworkVersions[frameworkVersion] {
//
//        } else {
//            // Use latest version? Or previous?
//        }
        
        
    }
    
}
