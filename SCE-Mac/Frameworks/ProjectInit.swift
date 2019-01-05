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
    
    var projectDirectory: URL {
        return URL(fileURLWithPath: baseDirectory).appendingPathComponent(projectName)
    }
    
    ///
    let frameworkCommands: FrameworkCommands
    
    let template: Template?
    
    let projectFileURL: URL
    
    init(projectName: String, baseDirectory: String, template: Template? = nil, frameworkName: String, frameworkVersion: String? = nil, platform: String? = nil) throws {
        
        self.projectName = projectName
        self.baseDirectory = baseDirectory
        self.template = template
        
        projectFileURL = URL(fileURLWithPath: baseDirectory).appendingPathComponent(projectName).appendingPathComponent("\(projectName).comp")
        
        frameworkCommands = try FrameworkCommands.loadCommands(for: frameworkName)
    }
    
    func initializeProject(output: @escaping (String)->Void, finished: @escaping (Int) -> Void) throws {
        
        // Fetch the right framework init
        let frameworkInit: FrameworkInit
        if let template = template, let commands = template.initType.commands(frameworkCommands) {
            frameworkInit = commands
        } else {
            frameworkInit = frameworkCommands.commands.initEmpty
        }
        
        let bashDirectory: String
        if frameworkInit.createProjectDirectory == true {
            bashDirectory = URL(fileURLWithPath: baseDirectory).appendingPathComponent(projectName).path
            try FileManager.default.createDirectory(atPath: bashDirectory, withIntermediateDirectories: true)
        } else {
            bashDirectory = baseDirectory
        }
        
        script = try ScriptTask(directory: bashDirectory, commands: frameworkInit.commands, output: { string in
            output(string)
        }, finished: { exitCode in
            
            // Copy files
            if let copyFiles = self.template?.copyFiles {
                for file in copyFiles {
                    do {
                        let newFilename = try file.copy(projectName: self.projectName, projectDirectory: self.projectDirectory)
                        output("Copied \(newFilename) to \(file.destination).")
                    } catch {
                        output("ERROR copying \(file.filename) to \(file.destination).")
                    }
                }
            }

            // Create .comp project file
            self.saveProjectFile()
            
            finished(exitCode)
        })
        script?.run()
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
    
    func cancel() {
        script?.terminate()
        script = nil
    }
}
