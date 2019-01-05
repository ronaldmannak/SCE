//
//  ProjectInit.swift
//  SCE
//
//  Created by Ronald "Danger" Mannak on 1/4/19.
//  Copyright © 2019 A Puzzle A Day. All rights reserved.
//

import Foundation


class ProjectInit {

    private var script: ScriptTask? = nil
    
    /// Name of the project (and project directory)
    let projectName: String

    /// The directory in which the project directory will be created.
    /// E.g. ~/Development/ The directory that will be created by ProjectInit
    /// will be ~/Development/<ProjectName>
    let baseDirectory: String
    
    ///
    let commands: FrameworkCommands

    /// If true, ProjectInit will create the project directory (<directory>/<projectName>) and run the commands in the project directory.
    /// If false, ProjectInit will run the commands in <directory>. This is how Embark works.
//    let createDirectory: Bool

    /// The Bash commands that will be executed to create the project
//    let commands: [String]

    /// List of files to be copied after the initialization.
    /// List is template-specific.
    let copyFiles: [CopyFile]?
    
    /// Name of file to be opened by default
    let openFile: String
    
//    let frameworkVersion: String?
    
    
    init(projectName: String, baseDirectory: String, openFile: String, copyFiles: [CopyFile]? = nil, frameworkName: String, frameworkVersion: String? = nil, platform: String? = nil) throws {
        
        self.projectName = projectName
        self.baseDirectory = baseDirectory
        commands = try FrameworkCommands.loadCommands(for: frameworkName)
        
        self.openFile = openFile
        self.copyFiles = copyFiles
    }
    
    func createProject(output: @escaping (String)->Void, finished: @escaping (Int) -> Void) throws { // finished: () -> Void
//        
//        let bashDirectory: String
//        if commands.commands.init createDirectory == true {
//            bashDirectory = URL(fileURLWithPath: baseDirectory).appendingPathComponent(projectName).path
//            try FileManager.default.createDirectory(atPath: bashDirectory, withIntermediateDirectories: true)
//        } else {
//            bashDirectory = baseDirectory
//        }
//        
//        script = try ScriptTask(directory: bashDirectory, commands: commands, output: { string in
//            output(string)
//        }, finished: { exitCode in
//            
//            // Copy files
//            if let copyFiles = self.copyFiles {
//                for file in copyFiles {
//                    file.copyfile()
//                    output("Copied \(file.filename) to \(file.destination).")
//                }
//            }
//            
//            // Create .comp project file
//            self.saveProjectFile()
//                
//            finished(exitCode)
//        })
        
        
    }
    
    private func saveProjectFile() {
        
        // save openFile in projectfile as lastOpenedFile
//        let encoder = PropertyListEncoder()
//        encoder.outputFormat = .xml
//        do {
//            let data = try encoder.encode(self.project)
//            FileManager.default.createFile(atPath: self.project.projectFileURL.path, contents: data, attributes: nil)
//        } catch {
//            print(error)
//            assertionFailure()
//        }
    }
    
    
    private func copy(file: CopyFile, output: @escaping (String)->Void) {
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
    
    func cancel() {
        script?.terminate()
        script = nil
    }
}
