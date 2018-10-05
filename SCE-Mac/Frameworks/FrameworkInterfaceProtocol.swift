//
//  FrameworkInterfaceProtocol.swift
//  SCE
//
//  Created by Ronald "Danger" Mannak on 9/20/18.
//  Copyright © 2018 A Puzzle A Day. All rights reserved.
//

import Foundation

protocol FrameworkInterfaceProtocol: Codable {
    
    static var name: String { get }
    
    var platform: Platform { get }
    
    var initFileURL: URL { get }
    
    
    init(_ platform: Platform)
    
    func initProject(output: @escaping (String)->Void, finished: @escaping () -> Void) throws -> ScriptTask
    func run()
    func lint()
    func debug()
}

// Default implementations
extension FrameworkInterfaceProtocol {
    
//    func initProject(output: @escaping (String)->Void, finished: @escaping () -> Void) throws -> ScriptTask {
//
//        // Closure copying custom files from bundle to project directory
//        let f: () -> Void = {
//
//            defer {
//                // Save initial project file to disk, so PreparingViewController can open it
//                self.saveProjectFile()
//                finished()
//            }
//
//            guard let copyFiles = self.copyFiles else { return }
//            for file in copyFiles {
//                self.copy(file: file)
//            }
//        }
//        var arguments: [String] = [project.baseDirectory.absoluteURL.path, project.name]
//        if let templateName = templateName {
//            arguments.append(templateName)
//        }
//        scriptTask = try ScriptTask(script: project.framework.initScript, arguments: arguments, output: output, finished: f)
//        scriptTask.run()
//        return scriptTask
//    }

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
