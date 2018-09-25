//
//  PlatformInterfaceProtocol.swift
//  SCE
//
//  Created by Ronald "Danger" Mannak on 9/20/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation

protocol PlatformInterfaceProtocol: Codable {
    
    static var name: String { get }
    
    var platform: Platform { get }
    
    init(_ platform: Platform)
    
    func run()
    func lint()
    func debug()
}

//extension PlatformInterfaceProtocol {
//    
//    init(from decoder: Decoder) throws {
//        
//    }
//    func encode(to encoder: Encoder) throws {
//        
//        
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(name, forKey: .name)
//        try container.encode(id, forKey: .id)
//        try container.encode(favoriteToy.name, forKey: .gift)
//    }
//}
//}
