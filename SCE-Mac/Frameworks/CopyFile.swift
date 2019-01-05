//
//  CopyFile.swift
//  SCE
//
//  Created by Ronald "Danger" Mannak on 1/4/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Foundation


struct CopyFile: Codable {
    let filename: String
    let destination: String
    let renameFileToProjectName: Bool
    
    func copyfile(projectName: String? = nil) {
        // ...
        //        guard let source = Bundle.main.url(forResource: file.filename, withExtension: nil) else {
        //            assertionFailure() // Source file does not exist in bundle
        //            return
        //        }
        //        let destination = self.project.workDirectory.appendingPathComponent(file.destination).appendingPathComponent(file.filename)
        //        do {
        //            try FileManager.default.copyItem(at: source, to: destination)
        //        } catch {
        //            print("****** \(error.localizedDescription) *****")
        //            print("From: \(source.path)")
        //            print("To: \(destination.path)")
        //            assertionFailure()
        //        }
    }
}

